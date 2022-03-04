import 'package:flutter/material.dart';

import '../model/text_model.dart';

class DisplayText extends StatelessWidget {
  final List<RecognizedText> _processedTexts;

  const DisplayText(this._processedTexts, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Found ${_processedTexts.length} items from image',
          ),
        ),
        const SizedBox(
          height: 5.0,
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _processedTexts.length,
            padding: const EdgeInsets.all(12.0),
            itemBuilder: (_, index) {
              return Center(
                child: ListTile(
                    title: Center(
                  child: SelectableText(
                      '${index + 1}: ${_processedTexts[index].block}'),
                )),
              );
            },
          ),
        ),
      ],
    );
  }
}
