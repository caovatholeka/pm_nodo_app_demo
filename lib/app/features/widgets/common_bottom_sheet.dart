import 'package:flutter/material.dart';
import 'package:pm_app/app/core/logger/logger.dart';
import 'package:pm_app/app/data/models/entities/master_data_item.dart';
import 'package:pm_app/app/features/widgets/radio_box_icon.dart';
import 'package:pm_app/app/features/widgets/radio_box_selected_icon.dart';

import '../../core/commons/app_colors.dart';
import '../../core/commons/app_shadow.dart';
import '../../core/commons/screen_size.dart';

class CommonBottomSheet extends StatefulWidget {
  final List<MasterDataItem>? listValues;
  final MasterDataItem? currentValue;
  final String? title;

  const CommonBottomSheet({
    super.key,
    this.listValues,
    this.currentValue,
    this.title,
  });


  @override
  State<CommonBottomSheet> createState() => _CommonBottomSheetState();
}

class _CommonBottomSheetState extends State<CommonBottomSheet> {
  @override
  Widget build(BuildContext context) {

    return Container(
      height: ScreenSize.of(context).height * 0.35,
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
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(
                    width: 24,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(widget.title ?? "",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal,
                        color: AppColors.themeBlackDefault,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: InkWell(
                            onTap: (){
                              Navigator.pop(context, widget.currentValue);
                            },
                            child: Center(child: Icon(Icons.close,size: 20,),)),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 18,),
            SizedBox(
                width: double.infinity,
                height: ScreenSize.of(context).height * 0.25,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: (widget.listValues ?? []).length,
                  itemBuilder: (context, index) {
                    MasterDataItem value = (widget.listValues ?? [])[index];
                    return Padding(
                      padding: const EdgeInsets.only(left: 12.0,right: 12),
                      child: InkWell(
                        onTap: (){
                          Navigator.pop(context, value);
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 12),
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
                                child: Text(value.text ?? "",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.normal,
                                      color: widget.currentValue?.code == value.code ?
                                      AppColors.themePrimaryDefault :
                                      AppColors.themeBlackDefault
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              widget.currentValue?.code == value.code ?
                              RadioBoxSelectedIcon() :
                              RadioBoxIcon(),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (buildContext, index) => Container(
                    height: 10,
                    color: Colors.white,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
