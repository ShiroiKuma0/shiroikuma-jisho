import 'package:filesystem_picker/src/widgets/marquee.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

/// Handles long filenames better, by adding ellipsis right before the file extension (if any)
class FilenameText extends StatelessWidget {
  final String filename;
  final bool isDirectory;
  final bool isUsed;
  final bool isActive;

  /// shiroikuma-jisho patch: a file the caller expects to be picked is
  /// written bold in [suggestedColor].
  final bool isSuggested;
  final Color? suggestedColor;
  final TextStyle? textStyle;

  const FilenameText(
    this.filename, {
    required this.isDirectory,
    required this.isUsed,
    required this.isActive,
    this.isSuggested = false,
    this.suggestedColor,
    this.textStyle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final txTheme = textStyle ?? Theme.of(context).textTheme.bodyLarge;
    final style = txTheme?.copyWith(
      color: isActive
          ? Colors.red
          : isSuggested
              ? suggestedColor
              : isUsed
                  ? Colors.grey
                  : null,
      fontWeight: isSuggested ? FontWeight.bold : null,
    );
    final fseName = path.basename(filename);
    final extension = path.extension(fseName);
    final hasExtension = extension.isNotEmpty;
    return Row(
      children: <Widget>[
        Flexible(
          child: JidoujishoMarquee(
            blankSpace: 50,
            text: isDirectory == false && hasExtension
                ? fseName.split(extension)[0]
                : fseName,
            style: style,
          ),
        ),
        Text(
          extension,
          maxLines: 1,
          overflow: TextOverflow.visible,
          style: style,
        ),
      ],
    );
  }
}
