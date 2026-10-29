import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/app/features/ui/work_trip/work_trip_cubit.dart';
import 'package:pm_app/app/features/widgets/file_action_bottom_sheet.dart';
import 'package:pm_app/app/features/widgets/group_attach_file.dart';
import 'package:pm_app/generated/l10n.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/commons/app_colors.dart';
import '../../core/commons/app_shadow.dart';
import '../../core/commons/screen_size.dart';
import '../../core/helper/attach_file_helper.dart';
import '../../core/logger/logger.dart';
import '../../core/utils/file_utils.dart';
import '../../data/local/attach_file.dart';
import '../../data/models/enums/load_status.dart';
import 'error_list_widget.dart';

class AttachFileBottomSheet extends StatefulWidget {
  final WorkTripCubit cubit;

  const AttachFileBottomSheet({super.key, 
    required this.cubit,
  });


  @override
  State<AttachFileBottomSheet> createState() => _AttachFileBottomSheetState();
}

class _AttachFileBottomSheetState extends State<AttachFileBottomSheet> {
  List<AttachFile> _fileUploads = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onAttachlickListener() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext bc) {
          return Wrap(children: <Widget>[_buildBottomSheet()]);
        });
  }

  void onCameraClickListener() async {
    if (_fileUploads.isEmpty ||
        (_fileUploads.isNotEmpty && _fileUploads.length < 5)) {
      List<AttachFile> list = await AttachFileHelper.shared.imageFromCamera;
      if (list.isNotEmpty &&
          FileUtils.getFileSize(list[0].file) > FileUtils.FILE_SIZE_LIMITED) {
        widget.cubit.warningTooLargeFile();
        return;
      }

      widget.cubit.addFile(list);
    } else {
      widget.cubit.warningTooManyFile();
    }

    logger.d("nodopm:  onImageClickListener");
  }

  void onImageClickListener() async {
    if (_fileUploads.isEmpty ||
        (_fileUploads.isNotEmpty && _fileUploads.length < 5)) {
      List<AttachFile> list = await AttachFileHelper.shared.imageFromLibrary;
      if (list.isNotEmpty &&
          list.isNotEmpty &&
          FileUtils.getFileSize(list[0].file) > FileUtils.FILE_SIZE_LIMITED) {
        widget.cubit.warningTooLargeFile();
        return;
      }
      widget.cubit.addFile(list);
    } else {
      widget.cubit.warningTooManyFile();
    }

    logger.d("quanth: 130816012020 onImageClickListener");
  }

  void onFileClickListener() async {
    if (_fileUploads.isEmpty ||
        (_fileUploads.isNotEmpty && _fileUploads.length < 5)) {
      List<AttachFile> list = await AttachFileHelper.shared.fileFromLibrary;
      if (list.isNotEmpty &&
          list.isNotEmpty &&
          FileUtils.getFileSize(list[0].file) > FileUtils.FILE_SIZE_LIMITED) {
        widget.cubit.warningTooLargeFile();
        return;
      }
      widget.cubit.addFile(list);
    } else {
      widget.cubit.warningTooManyFile();
    }
  }

  void _pressCloseListener(String id) {
    widget.cubit.deleteFile(id);
  }

  Future<void> _onRefreshData() async {}


  Widget _buildBottomSheet() {
    return FileActionBottomSheet(
      onCameraClickListener: onCameraClickListener,
      onImageClickListener: onImageClickListener,
      onFileClickListener: onFileClickListener,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenSize.of(context).height * 0.5,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
        boxShadow: AppShadow.boxShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 24,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(S.of(context).common_add_documents,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: AppColors.themeDarkDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: InkWell(
                          onTap: (){
                            Navigator.of(context).pop();
                          },
                          child: Center(child: SvgPicture.asset(AppAssets.icClose,width: 20,),)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                _onAttachlickListener();
              },
              child: DottedBorder(
                dashPattern: const [4, 4],
                strokeWidth: 1,
                strokeCap: StrokeCap.round,
                borderType: BorderType.RRect,
                radius: const Radius.circular(4),
                child: Container(
                  height: 76,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppAssets.icCloud),
                      Container(
                          margin: const EdgeInsets.only(left: 4),
                          child: Text(S.of(context).common_upload_documents, style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.themeDarkLight
                          ),)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8,),
            _buildAttachFiles(),
            const SizedBox(height: 8,),
            InkWell(
              onTap: (){
                Navigator.of(context).pop();
              },
              child: Container(
                height: 50,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
                decoration: BoxDecoration(
                    color: AppColors.themePrimaryDefault,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                        width: 1,
                        color: Colors.black.withAlpha(10)
                    )
                ),
                child: Center(
                  child: Text(
                    S.of(context).common_agree_upper,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  double imageSize = 105;
  double imagePadding = 10;
  double loadingSize = 38;

  Widget _buildLoadingFile({String? name}) {
    return SizedBox(
      width: imageSize + imagePadding,
      height: imageSize + imagePadding * 2,
      child: Stack(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[350]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
                height: imageSize,
                width: imageSize,
                margin: EdgeInsets.only(top: imagePadding, right: imagePadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                )),
          ),
        ],
      ),
    );
  }
  Widget _buildFailureList() {
    return ErrorListWidget(
      onRefresh: _onRefreshData,
    );
  }

  Widget _buildAttachFiles() {
    return SizedBox(
      height: ScreenSize.of(context).height * 0.21,
      width: double.infinity,
      child: BlocBuilder<WorkTripCubit,WorkTripState>(
          bloc: widget.cubit,
          buildWhen: (prev,cur) => prev.addFileStatus != cur.addFileStatus,
          builder: (context, state) {
            if (state.addFileStatus == LoadStatus.LOADING){
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: imageSize,
                child: Row(
                  children: [
                    Expanded(child: _buildLoadingFile(name: "aaa")),
                    Expanded(child: _buildLoadingFile(name: "bbb")),
                    Expanded(child: _buildLoadingFile(name: "ccc")),
                  ],
                ),
              );
            }else if(state.addFileStatus == LoadStatus.FAILURE){
              return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 150,
                  child: _buildFailureList());
            }else{
              _fileUploads = state.files;
              return GroupAttachFile(
                imageList: state.files,
                callback: _pressCloseListener,
              );
            }
          }),
    );
  }
}
