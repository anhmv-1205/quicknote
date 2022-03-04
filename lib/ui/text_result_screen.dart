import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/text_cubit.dart';
import '../components/display_text.dart';

class TextResultScreen extends StatefulWidget {
  const TextResultScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TextResultScreenState();
}

class _TextResultScreenState extends State<TextResultScreen> {
  @override
  void initState() {
    BlocProvider.of<TextRecognizedCubit>(context).getText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detected Result"),
      ),
      body: BlocBuilder<TextRecognizedCubit, TextRecognizedState>(
          builder: (context, state) {
        if (state is TextRecognizedLoading) {
          return const Center(
            child: SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is TextRecognizedError) {
          return Center(child: Text(state.errorMessage ?? "Error"));
        } else if (state is TextRecognizedLoaded &&
            state.processedTexts != null &&
            state.processedTexts!.isNotEmpty) {
          return DisplayText(state.processedTexts!);
        }
        return const Center(child: Text('Nothing here 😴'));
      }),
    );
  }
}
