import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pm_app/app/data/models/entities/user_entity.dart';

import '../../../../core/commons/app_colors.dart';
import '../../../../core/commons/screen_size.dart';
import '../../../widgets/check_box_icon.dart';
import '../../../widgets/check_box_selection.dart';
import '../../../widgets/input_text_field.dart';
import '../../../widgets/primary_button.dart';

class SelectUserBottomSheet extends StatefulWidget {
  final List<UserEntity>? listUsers;
  final ValueChanged<List<UserEntity>>? onUsersSelected;
  final List<UserEntity>? listCurrentUsers;

  const SelectUserBottomSheet({
    super.key,
    this.listUsers,
    this.onUsersSelected,
    this.listCurrentUsers
  });

  @override
  State<SelectUserBottomSheet> createState() => _SelectUserBottomSheetState();
}

class _SelectUserBottomSheetState extends State<SelectUserBottomSheet> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController  = TextEditingController();
  final FocusNode _focusSearch = FocusNode();

  List<UserEntity> listUserSelected = [];
  List<UserEntity> _filteredUsers = [];

  bool isShowSuffix = false;
  @override
  void initState() {
    _scrollController.addListener(() {
      _dismissKeyboard();
    });

    _focusSearch.addListener(() {
      if (!_focusSearch.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
    listUserSelected = List.from(widget.listCurrentUsers ?? []);
    _filteredUsers = List.from(widget.listUsers ?? []);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  // filter school
  void filterSchool(String query) {
    final source = widget.listUsers ?? [];
    final q = query.trim().toLowerCase();

    setState(() {
      if (q.isEmpty) {
        _filteredUsers = List.from(source);
      } else {
        _filteredUsers = source.where((s) {
          final name = (s.name ?? '').toLowerCase();
          return name.contains(q);
        }).toList();
      }
      // toggle nút clear
      isShowSuffix = q.isNotEmpty;
    });
  }

  onChangeSuffix(String value){
    setState(() {
      value.isNotEmpty ? isShowSuffix == true : false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader("Người được phân công"),
          const SizedBox(height: 10,),
          _buildContent,
          _buildFooter,
          // const SizedBox(height: 24,)
        ],
      ),
    );
  }

  Widget _buildHeader(String title){
    return Container(
      margin: EdgeInsets.only(top: 12),
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 18.0),
              child: InkWell(
                  onTap: (){
                    // close popup
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Icon(Icons.close,size: 18,)
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Text(title,style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.normal,
              color: AppColors.themeBlackDefault,
            ),),
          ),
        ],
      ),
    );
  }

  get _buildContent {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: ScreenSize.of(context).height * 0.7,
          width: double.infinity,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: _buildAllFilterContent,
          ),
        )
      ],
    );
  }
  get _buildFooter{
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 15),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Row(
          children: [
            Expanded(
              child: PrimaryButton(
                mainText: "Xác Nhận",
                callback: (){
                  Navigator.pop(context);
                  widget.onUsersSelected!(listUserSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  get _buildAllFilterContent {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(left: 8,right: 8,bottom: 12),
            child: InputTextField(
              title: "",
              disableTitle: true,
              hintText: "Tìm kiếm thêm",
              isRequiredField: false,
              bgrColor: true,
              controller: _searchController,
              onChange: (value) {
                filterSchool(value);
              },
              // suffixIcon: isShowSuffix ? AppAssets.icClose : null,
              // onSuffixAction: (){
              //
              // },
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _filteredUsers.map((user) {
              return InkWell(
                onTap: (){
                  List<UserEntity> temp;
                  if(listUserSelected.isNotEmpty){
                    temp = List.from(listUserSelected);
                  }else{
                    temp = [];
                  }
                  if (temp.any((e)=> e.id == user.id) == true) {
                    temp.removeWhere((e) => e.id == user.id);
                  } else {
                    temp.add(user);
                  }
                  setState(() {
                    listUserSelected = List.from(temp);
                  });

                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          width: 1,
                          color: Colors.black.withAlpha(10)
                      )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(user.name ?? "",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              color:(listUserSelected.any((e) => e.id== user.id) == true) ?
                              AppColors.themePrimaryDefault :
                              AppColors.themeBlackDefault
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      (listUserSelected.any((e) => e.id == user.id) == true) ?
                      CheckBoxSelection() :
                      CheckBoxIcon(),
                    ],
                  ),
                ),
              ).paddingOnly(bottom: 10);
            } ).toList(),
          ),
        ],
      ),
    );
  }
}