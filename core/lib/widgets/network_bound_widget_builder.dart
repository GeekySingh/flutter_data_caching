import 'package:flutter/widgets.dart';

typedef AsyncWidgetBuilder<T> = Widget Function(
    BuildContext context, T snapshot);

class NetworkBoundWidgetBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncWidgetBuilder<T> builder;

  NetworkBoundWidgetBuilder({required this.stream, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return builder(context, snapshot.data!);
          } else {
            return Center(child: Text('Snapshot data is null!'));
          }
        });
  }
}
