import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/core/commons/app_colors.dart';
import 'package:pm_app/app/features/widgets/primary_button.dart';
import 'package:pm_app/app/data/models/enums/load_status.dart';
import 'otp_verify_cubit.dart';
import 'package:pm_app/app/features/ui/auth/login/login_page.dart';
import 'package:another_flushbar/flushbar.dart';

class OtpVerifyPage extends StatefulWidget {
  final String email;
  final String? password;
  final String? confirmPassword;

  const OtpVerifyPage({
    super.key,
    required this.email,
    this.password,
    this.confirmPassword,
  });

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());

  Timer? _timer;
  int _timeLeft = 120;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 120;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft == 0) {
        timer.cancel();
        setState(() {});
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  String _formatTime() {
    final m = (_timeLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_timeLeft % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _onSubmit() {
    final otp = _otpCtrls.map((e) => e.text).join();
    if (otp.length != 6) {
      Flushbar(
        message: "Mã OTP chưa đủ 6 ký tự",
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(12),
      ).show(context);
      return;
    }

    context.read<OtpVerifyCubit>().verifyOTP(email: widget.email, otp: otp);
  }

  void _onResend() {
    if (_timeLeft > 0) return;

    context.read<OtpVerifyCubit>().resendOTP(
          email: widget.email,
          password: widget.password ?? "",
          confirmPassword: widget.confirmPassword ?? "",
        );

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpVerifyCubit, OtpVerifyState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          Flushbar(
            message: state.errorMessage!,
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(12),
          ).show(context);
          return;
        }

        if (state.verifyStatus == LoadStatus.SUCCESS) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
          return;
        }

        if (state.resendStatus == LoadStatus.SUCCESS &&
            state.verifyStatus != LoadStatus.LOADING) {
          Flushbar(
            message: "Mã OTP mới đã được gửi",
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
            margin: const EdgeInsets.all(12),
          ).show(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  AppAssets.appBG2,
                  fit: BoxFit.cover,
                ),
              ),

              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.92,
                      padding: const EdgeInsets.fromLTRB(26, 28, 26, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(AppAssets.appLogo2, width: 120),

                          const SizedBox(height: 14),

                          const Text(
                            "Xác thực mã OTP",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "Vui lòng nhập mã OTP được gửi đến email của bạn.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.35,
                            ),
                          ),

                          const SizedBox(height: 26),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (i) => _otpBox(i)),
                          ),

                          const SizedBox(height: 18),

                          _timeLeft > 0
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Mã sẽ hết hạn sau ",
                                        style: TextStyle(fontSize: 13)),
                                    Text(
                                      _formatTime(),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.blueAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: state.resendStatus ==
                                          LoadStatus.LOADING
                                      ? null
                                      : _onResend,
                                  child: const Text(
                                    "Gửi lại mã OTP",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                          const SizedBox(height: 26),

                          PrimaryButton(
                            mainText: "Xác nhận",
                            isLoading:
                                state.verifyStatus == LoadStatus.LOADING,
                            callback: _onSubmit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 28,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info_outline,
                          size: 16, color: Color(0xFFB5BBC6)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Nếu bạn gặp vấn đề, vui lòng liên hệ với phòng nhân sự của công ty để được hỗ trợ.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB5BBC6),
                            height: 1.25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 46,
      child: TextField(
        controller: _otpCtrls[index],
        onChanged: (value) {
          if (value.length == 1 && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(
              color: AppColors.themePrimaryDefault,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
