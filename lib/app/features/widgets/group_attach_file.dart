import 'package:flutter/material.dart';

import '../../core/logger/logger.dart';
import '../../data/local/attach_file.dart';
import 'file_attach_cell.dart';

class GroupAttachFile extends StatefulWidget {
  final List<AttachFile> imageList;
  final Function callback;

  GroupAttachFile({
    required this.imageList,
    required this.callback,
  });

  @override
  State<GroupAttachFile> createState() => _GroupAttachFileState();
}

class _GroupAttachFileState extends State<GroupAttachFile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      height: (widget.imageList.isNotEmpty) ? 150 : 0,
      child: (widget.imageList.isNotEmpty)? ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.imageList.length,
        itemBuilder: (_, int index) => FileAttachCell(
          file: widget.imageList[index],
          index: index,
          callback: _pressCloseListener,
        ),
      ) : Container(),
    );
  }

  void _pressCloseListener(String id) {
    widget.callback(id);
    logger.d("Press cell ImageAttachGroup fileId = ${id}");
  }

}
