import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';
import 'package:pm_app/generated/l10n.dart';

import '../../core/commons/app_colors.dart';

class FileActionBottomSheet extends StatelessWidget {
  final VoidCallback? onCameraClickListener;
  final VoidCallback? onImageClickListener;
  final VoidCallback? onFileClickListener;

  const FileActionBottomSheet({super.key, 
    this.onCameraClickListener,
    this.onImageClickListener,
    this.onFileClickListener,
  });

  final double largeMargin = 15;
  final double smallMargin = 10;
  final double spaced = 10;
  final double border = 1;
  final double dropIconWidth = 20;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(19.0),
          topLeft: Radius.circular(19.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.all(largeMargin),
                  width: largeMargin * 2,
                  height: largeMargin * 2),
              Flexible(
                child: Text(
                  s.common_select_files_to_upload,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: EdgeInsets.all(largeMargin),
                  width: largeMargin * 2,
                  height: largeMargin * 2,
                  child: Icon(
                    Icons.close,
                    color: Colors.blueGrey,
                  ),
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: Colors.grey,
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      if (Platform.isAndroid) {
                        PermissionStatus? permissionCamera =
                        await Permission.camera.status;
                        if (permissionCamera != PermissionStatus.granted) {
                          Permission.camera.request().then((permission) {
                            if (permission == PermissionStatus.granted) {
                              onCameraClickListener?.call();
                              Navigator.pop(context);
                            }
                          });
                        }
                      } else {
                        onCameraClickListener?.call();
                        Navigator.pop(context);
                      }
                    },
                    child: _buildItem(
                        icon: AppAssets.icAttachCamera,
                        title: s.common_take_photo,
                        color: AppColors.textGray600),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      final popContext = Navigator.of(context);
                      if (Platform.isAndroid) {
                        final androidInfo =
                        await DeviceInfoPlugin().androidInfo;
                        if ((androidInfo.version.sdkInt ?? 0) <= 32) {
                          PermissionStatus? permissionPhoto =
                          await Permission.storage.status;
                          if (permissionPhoto != PermissionStatus.granted) {
                            Permission.storage.request().then((permission) {
                              if (permission == PermissionStatus.granted) {
                                onImageClickListener?.call();
                                Navigator.pop(context);
                              }
                            });
                          } else {
                            onImageClickListener?.call();
                            popContext.pop();
                          }
                        } else {
                          PermissionStatus? permissionPhoto =
                          await Permission.photos.status;
                          if (permissionPhoto != PermissionStatus.granted) {
                            Permission.photos.request().then((permission) {
                              if (permission == PermissionStatus.granted) {
                                onImageClickListener?.call();
                                Navigator.pop(context);
                              }
                            });
                          } else {
                            onImageClickListener?.call();
                            popContext.pop();
                          }
                        }
                      } else {
                        onImageClickListener?.call();
                        Navigator.pop(context);
                      }
                    },
                    child: _buildItem(
                        icon: AppAssets.icAttachFile,
                        title: s.common_photo_library,
                        color: AppColors.themeBlackDefault),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: GestureDetector(
                    onTap: () async {
                      if (Platform.isAndroid) {
                        PermissionStatus? permissionFile =
                        await Permission.manageExternalStorage.status;
                        if (permissionFile != PermissionStatus.granted) {
                          Permission.storage.request().then((permission) {
                            if (permission == PermissionStatus.granted) {
                              onFileClickListener?.call();
                              Navigator.pop(context);
                            }
                          });
                        }
                      } else {
                        onImageClickListener?.call();
                        Navigator.pop(context);
                      }
                    },
                    child: _buildItem(
                        icon: AppAssets.icAttachImage,
                        title: s.common_documents,
                        color: AppColors.themePrimaryDefault),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
      {required String icon, required String title, required Color color}) {
    return Column(
      children: [
        CircleAvatar(
          minRadius: 30,
          backgroundColor: color,
          child: Container(
            padding: EdgeInsets.all(5),
            height: 50,
            child: Image.asset(icon),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(top: smallMargin * 0.5),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textGray600),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
