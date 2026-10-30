import 'package:flame_studio/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template home_page}
/// The screen shown when no project is open.
/// {@endtemplate}
class const HomePage({super.key}) extends StatelessWidget {
  /// {@macro home_page}
  this;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          HomeBloc(projectRepository: context.read())
            ..add(const HomeRecentProjectsRequested()),
      child: const HomeView(),
    );
  }
}
