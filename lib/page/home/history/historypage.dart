import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:beer_me_up/common/widget/beertile.dart';
import 'package:beer_me_up/common/widget/loadingwidget.dart';
import 'package:beer_me_up/common/widget/erroroccurredwidget.dart';
import 'package:beer_me_up/model/checkin.dart';
import 'package:beer_me_up/service/userdataservice.dart';
import 'package:beer_me_up/common/mvi/viewstate.dart';

import 'model.dart';
import 'intent.dart';
import 'state.dart';

class HistoryPage extends StatefulWidget {
  final HistoryIntent intent;
  final HistoryViewModel model;

  HistoryPage._({
    Key key,
    @required this.intent,
    @required this.model,
  }) : super(key: key);

  factory HistoryPage({Key key,
    HistoryIntent intent,
    HistoryViewModel model,
    UserDataService dataService}) {

    final _intent = intent ?? new HistoryIntent();
    final _model = model ?? new HistoryViewModel(
      dataService ?? UserDataService.instance,
      _intent.retry,
      _intent.loadMore,
    );

    return new HistoryPage._(key: key, intent: _intent, model: _model);
  }

  @override
  _HistoryPageState createState() => new _HistoryPageState(intent: intent, model: model);
}

class _HistoryPageState extends ViewState<HistoryPage, HistoryViewModel, HistoryIntent, HistoryState> {
  static final _listSectionDateFormatter = new DateFormat.yMMMMd();

  _HistoryPageState({
    @required HistoryIntent intent,
    @required HistoryViewModel model
  }): super(intent, model);

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot<HistoryState> snapshot) {
        if( !snapshot.hasData ) {
          return new Container();
        }

        return snapshot.data.join(
          (loading) => _buildLoadingWidget(),
          (load) => _buildLoadWidget(items: load.items),
          (error) => _buildErrorWidget(error: error.error),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return new LoadingWidget();
  }

  Widget _buildErrorWidget({@required String error}) {
    return new ErrorOccurredWidget(
      error,
      intent.retry
    );
  }

  Widget _buildLoadWidget({@required List<HistoryListItem> items}) {
    return new ListView.builder(
      itemCount: items.length,
      padding: const EdgeInsets.all(20.0),
      itemBuilder: (BuildContext context, int index) {
        final item = items[index];

        if( item is HistoryListSection ) {
          return _buildListSectionWidget(item.date);
        } else if( item is HistoryListRow ) {
          return _buildListRow(item.checkIn);
        } else if( item is HistoryListLoadMore ) {
          return _buildListLoadMore();
        } else if( item is HistoryListLoading ) {
          return _buildListLoadingMore();
        }

        return new Container();
      },
    );
  }

  Widget _buildListSectionWidget(DateTime date) {
    return new Text(
      _listSectionDateFormatter.format(date)
    );
  }

  Widget _buildListRow(CheckIn checkIn) {
    return new BeerTile(
      beer: checkIn.beer,
      associatedCheckin: checkIn,
    );
  }

  Widget _buildListLoadMore() {
    return new RaisedButton(
      onPressed: intent.loadMore,
      child: new Text("Load more"),
    );
  }

  Widget _buildListLoadingMore() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}