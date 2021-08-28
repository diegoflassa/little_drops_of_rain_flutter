import 'package:flutter/material.dart';
import 'package:little_drops_of_rain_flutter/enums/element_type.dart';
import 'package:little_drops_of_rain_flutter/enums/order_by.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/interfaces/on_order_by_change.dart';

class OrderByWidget extends StatefulWidget {
  const OrderByWidget(
      {required this.elementType,
      Key? key,
      this.orderBy = OrderBy.UPDATE_DATE,
      this.orderDirection = false,
      this.onOrderByChange})
      : super(key: key);

  final ElementType elementType;
  final OnOrderByChange? onOrderByChange;
  final OrderBy orderBy;
  final bool orderDirection;

  @override
  _OrderByWidgetState createState() => _OrderByWidgetState();
}

class _OrderByWidgetState extends State<OrderByWidget> {
  OrderBy? _valueOrderBy = OrderBy.UPDATE_DATE;
  bool _valueOrderDirection = false;

  @override
  void initState() {
    super.initState();
    _valueOrderBy = widget.orderBy;
    _valueOrderDirection = widget.orderDirection;
  }

  @override
  Widget build(BuildContext context) {
    return _getOrderBySizedRow();
  }

  Row _getOrderBySizedRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _getDropDownOrderBy(),
        const SizedBox(width: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
        _getDropDownOrderDirection(),
      ],
    );
  }

  DropdownButton<OrderBy> _getDropDownOrderBy() {
    return DropdownButton<OrderBy>(
      value: _valueOrderBy,
      items: [
        DropdownMenuItem(
          value: OrderBy.RANDOM,
          child: Text(AppLocalizations.of(context).random),
        ),
        DropdownMenuItem(
          value: OrderBy.ALPHABETICALLY,
          child: Text(AppLocalizations.of(context).alphabetically),
        ),
        DropdownMenuItem(
          value: OrderBy.CREATION_DATE,
          child: Text(AppLocalizations.of(context).creationDate),
        ),
        if (widget.elementType != ElementType.UNIVERSE)
          DropdownMenuItem(
            value: OrderBy.UPDATE_DATE,
            child: Text(AppLocalizations.of(context).updateDate),
          ),
        if (widget.elementType != ElementType.UNIVERSE)
          DropdownMenuItem(
            value: OrderBy.VIEWS,
            child: Text(AppLocalizations.of(context).views),
          ),
        if (widget.elementType == ElementType.HERO)
          DropdownMenuItem(
            value: OrderBy.RATING,
            child: Text(AppLocalizations.of(context).rating),
          ),
      ],
      onChanged: (value) {
        setState(() {
          _valueOrderBy = value;
          widget.onOrderByChange?.onOrderByChange(value);
        });
      },
    );
  }

  DropdownButton<bool> _getDropDownOrderDirection() {
    return DropdownButton<bool>(
      value: _valueOrderDirection,
      items: [
        DropdownMenuItem(
          value: true,
          child: Text(AppLocalizations.of(context).descending),
        ),
        DropdownMenuItem(
          value: false,
          child: Text(AppLocalizations.of(context).ascending),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _valueOrderDirection = value!;
          widget.onOrderByChange?.onOrderDirectionChange(value);
        });
      },
    );
  }
}
