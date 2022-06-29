import 'package:flutter/material.dart';
import 'package:flutterPaginationApi/bloc/selectedUserIdBloc.dart';
import 'package:flutterPaginationApi/models/UsersResponse.dart';

import 'package:flutterPaginationApi/screens/user/userDetailScreen.dart';
import 'package:flutterPaginationApi/screens/user/userScreen.dart';
import 'package:flutterPaginationApi/utility/apiManager.dart';
import 'package:flutterPaginationApi/utility/appStrings.dart';
import 'package:flutterPaginationApi/utility/utiity.dart';
import 'package:flutterPaginationApi/widgets/fullScreenImageSlider.dart';
import 'package:flutterPaginationApi/widgets/userItemView.dart';

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  List<UserDetails> userDetails = List();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool isLoading = false;

  getUsers() async {
    //first check for internet connectivity
    if (await ApiManager.checkInternet()) {
      //show progress
      if (mounted)
        setState(() {
          isLoading = true;
        });

      var request = Map<String, dynamic>();

      //convert json response to class
      UsersResponse response = UsersResponse.fromJson(
        await ApiManager(context).getCall(
          url: AppStrings.USERS,
          request: request,
        ),
      );

      //hide progress
      if (mounted)
        setState(() {
          isLoading = false;
        });

      if (response != null) {
        if (response.data.length > 0) {
          if (mounted) {
            setState(() {
              //add paginated list data in list
              userDetails.addAll(response.data);
            });
          }
        }
      }
    } else {
      //if no internet connectivity available then show apecific message
      Utility.showToast("No Internet Connection");
    }
  }

  refresh() {
    //to refresh page
    if (mounted)
      setState(() {
        userDetails.clear();
      });
    getUsers();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => UserScreen()))),
        centerTitle: true,
        title: Text("Users"),
        actions: [
          Utility.githubAction(),
        ],
      ),
      body: body(),
    );
  }

  Widget body() {
    return Stack(
      children: <Widget>[
        RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () async {
            refresh();
          },
          child: !isLoading && userDetails.length == 0
              /*

                i have shown empty view in list view because refresh indicator will not work if there is no list.

              */
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height -
                          ((AppBar().preferredSize.height * 2) + 30),
                      child: Utility.emptyView("No Users"),
                    ),
                  ],
                )

              //try this code you can see that refresh indicator will not work
              // return Utility.emptyView("No Users");

              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: 12,
                  ),
                  itemCount: userDetails.length,
                  itemBuilder: (BuildContext context, int index) {
                    return itemView(index);
                  },
                ),
        ),

        //show progress
        isLoading ? Utility.progress(context) : Container(),
      ],
    );
  }

  Widget itemView(int index) {
    //users item view
    return UserItemView(
      userDetails: userDetails[index],
      onTap: () {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => UserDetailScreen(
              selectedUserId: userDetails[index].id,
            ),
          ),
        );
      },
      onImageTap: () {
        showDialog(
          builder: (context) {
            return AlertDialog(
              content: Container(
                height: 250,
                width: 250,
                child: FullScreenImageSlider(
                  imagelist: [userDetails[index].avatar],
                  selectedimage: 100,
                ),
              ),
            );
          },
          context: context,
        );
      },
    );
  }
}
