import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef ChildDataWidget<T> = Widget Function(BuildContext context, T data);

class NetworkBoundWidget<T> extends StatelessWidget {
  final Stream<Resource<T?>> stream;
  final ChildDataWidget<T> child;
  final Widget? loading;
  final Widget? failure;
  final Widget? error;

  NetworkBoundWidget(
      {required this.stream,
      required this.child,
      this.loading,
      this.failure,
      this.error});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Resource<T?>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final networkBoundData = snapshot.data!.data;
            switch (snapshot.data!.status) {
              case Status.LOADING:
                if (networkBoundData == null || (networkBoundData is List && networkBoundData.isEmpty))
                  return loading ?? Center(child: CircularProgressIndicator());
                else
                  return child(context, networkBoundData);
              case Status.SUCCESS:
                return child(context, networkBoundData!);
              case Status.FAILURE:
                return failure ??
                    Center(
                        child: Text(snapshot.data!.failureDetails?.message ??
                            'Data fetch failure!'));
              case Status.EXCEPTION:
                return error ??
                    Center(
                        child: Text(snapshot.data!.exceptionDetails?.exception
                                .toString() ??
                            'An exception occurred while fetching data!'));
            }
          } else {
            return error ?? Center(child: Text(snapshot.error.toString()));
          }
        });
  }
}
