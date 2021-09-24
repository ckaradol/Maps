import 'package:flutter/material.dart';
import 'package:map/bacground/Login/login_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DataMarker extends StatelessWidget {
  const DataMarker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoginState state=context.read<LoginBloc>().state;
    if(state is LoginCenterState) {
      return Container(
        child: Image.asset("assets/images/motokurye.png"),
      );
    }else if(state is LoginUserState){

      return Container(
        child: Image.asset("assets/images/market.png"),
      );
    }else{
      return Container();
    }
  }
}
