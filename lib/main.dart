import 'package:bloc_flutter/bloc/image_cubit.dart';
import 'package:bloc_flutter/bloc/text_cubit.dart';
import 'package:bloc_flutter/components/components_layer.dart';
import 'package:bloc_flutter/ui/text_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ImageCubit()),
        BlocProvider(
          create: (context) => TextRecognizedCubit()
            ..imageCubit = BlocProvider.of<ImageCubit>(context),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlocConsumer<ImageCubit, ImageState>(
              listener: (context, state) {
                print(state.toString());
              },
              builder: (context, state) {
                final bloc = BlocProvider.of<ImageCubit>(context);
                if (state is ImageLoading) {
                  return const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator());
                } else if (state is ImageLoaded &&
                    state.image?.imagePath != null &&
                    state.image?.imagePath?.isNotEmpty == true) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DisplayImage(bloc.image?.imagePath),
                      CustomButton(
                        title: "Get another image",
                        onTap: () {
                          bloc.getImage();
                        },
                      ),
                    ],
                  );
                }
                return CustomButton(
                  title: "Upload image",
                  onTap: () {
                    bloc.getImage();
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _gotoResultScreen,
        tooltip: 'Increment',
        child: const Icon(Icons.arrow_right_sharp),
      ),
    );
  }

  void _gotoResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TextResultScreen(),
      ),
    );
  }
}
