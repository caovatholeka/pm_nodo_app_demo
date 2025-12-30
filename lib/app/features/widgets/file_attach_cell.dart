import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:pm_app/app/core/commons/app_assets.dart';

import '../../core/commons/app_colors.dart';
import '../../core/helper/attach_file_helper.dart';
import '../../core/logger/logger.dart';
import '../../data/local/attach_file.dart';

class FileAttachCell extends StatefulWidget {
  final AttachFile file;
  final Function callback;
  final int index;

  const FileAttachCell({super.key, required this.file, required this.callback, required this.index});

  @override
  State<FileAttachCell> createState() => _FileAttachCellState();
}

class _FileAttachCellState extends State<FileAttachCell> {
  double imageSize = 105;
  double imagePadding = 10;
  double loadingSize = 38;

  @override
  Widget build(BuildContext context) {
    return _buildImageItem(widget.file);
  }

  Widget _buildImageItemByAsset({required Asset asset, required String name}) {
    return SizedBox(
      width: imageSize + imagePadding / 2,
      height: imageSize + imagePadding / 2,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: imagePadding, right: imagePadding),
                width: imageSize,
                height: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: AssetThumb(
                    quality: 100,
                    asset: asset,
                    width: 1000,
                    height: 1000,
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Container(
                padding: EdgeInsets.only(right: imagePadding * 2, left: imagePadding * 0.5),
                child: Text(
                  name,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF333333)
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                logger.d(
                    "Press cell ImageAttachCell fileId = ${widget.file.id}");
                widget.callback(widget.file.id);
              },
              child: Container(
                padding: EdgeInsets.all(imagePadding/1.5),
                width: 30,
                height: 30,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset(AppAssets.icClose),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageItemByPath({required String path, required String name}) {
    return SizedBox(
      width: imageSize + imagePadding / 2,
      height: imageSize + imagePadding / 2,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: imagePadding, right: imagePadding),
                width: imageSize,
                height: imageSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Image.file(
                    File(path),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Container(
                padding: EdgeInsets.only(right: imagePadding * 2, left: imagePadding * 0.5),
                child: Text(
                  name,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF333333)
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                logger.d(
                    "quanth: press cell ImageAttachCell fileId = ${widget.file.id}");
                widget.callback(widget.file.id);
              },
              child: Container(
                padding: EdgeInsets.all(imagePadding/1.5),
                width: 30,
                height: 30,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset(AppAssets.icClose),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageItemByUrlPath({required String imgUrl, required String name}) {
    return SizedBox(
      width: imageSize + imagePadding / 2,
      height: imageSize + imagePadding / 2,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: imagePadding, right: imagePadding),
                width: imageSize,
                height: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: Container(
                        width: loadingSize,
                        height: loadingSize,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          valueColor:
                          new AlwaysStoppedAnimation<Color>(Color(0xff0088CB)),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Container(
                padding: EdgeInsets.only(right: imagePadding * 2, left: imagePadding * 0.5),
                child: Text(
                  name,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF333333)
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                logger.d(
                    "press cell ImageAttachCell fileId = ${widget.file.id}");
                widget.callback(widget.file.id);
              },
              child: Container(
                padding: EdgeInsets.all(imagePadding/1.5),
                width: 30,
                height: 30,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset(AppAssets.icClose),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFile({required String name}) {
    return SizedBox(
      width: imageSize + imagePadding / 2,
      height: imageSize + imagePadding / 2,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(top: imagePadding, right: imagePadding),
                width: imageSize,
                height: imageSize,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Image.asset(AppAssets.icAttachPDF),
                ),
              ),
              SizedBox(height: 5,),
              Container(
                padding: EdgeInsets.only(right: imagePadding * 2, left: imagePadding * 0.5),
                child: Text(
                  name,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textGray600
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: InkWell(
              onTap: () {
                logger.d(
                    "press cell ImageAttachCell fileId = ${widget.file.id}");
                widget.callback(widget.file.id);
              },
              child: Container(
                padding: EdgeInsets.all(imagePadding/1.5),
                width: 30,
                height: 30,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Image.asset(AppAssets.icClose),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildImageItem(AttachFile file) {
    if(!AttachFileHelper.shared.isImageFile(file.mime)) {
      return _buildFile(name: file.name ?? '');
    } else if (file.asset != null){
      return _buildImageItemByAsset(asset: file.asset!, name: file.name ?? '');
    }
    else if (file.path != null){
      return _buildImageItemByPath(path: file.path!, name: file.path!);
    }

    else if (file.file != null){
      return _buildImageItemByPath(path: file.file!.path, name: file.file!.path);
    }
    else{
      return _buildImageItemByUrlPath(imgUrl: file.urlPath ?? '', name: file.name ?? '');
    }
  }
}
