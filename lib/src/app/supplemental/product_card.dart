// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:shrine_example_app/src/model.dart' show AppStateModel, Product;
// import 'package:scoped_model/scoped_model.dart';

import 'package:shrine_example_app/src/view.dart' show SetState;

///
class ProductCard extends StatelessWidget {
  ///
  const ProductCard({
    Key? key,
    this.imageAspectRatio = 33 / 49,
    required this.product,
    this.isOnWeb = false,
  })  : assert(imageAspectRatio == null || imageAspectRatio > 0),
        super(key: key);

  ///
  final double? imageAspectRatio;

  ///
  final Product product;

  ///
  static const double kTextBoxHeight = 65;

  ///
  final bool? isOnWeb;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat.simpleCurrency(
      decimalDigits: 0,
      locale: Localizations.localeOf(context).toString(),
    );

    final ThemeData theme = Theme.of(context);

    final Image imageWidget = Image.asset(
      'assets/${product.assetName}',
      fit: isOnWeb ?? false ? BoxFit.none : BoxFit.cover,
    );
//    package: product.assetPackage,

    return SetState(
        builder: (context, _) => GestureDetector(
              onTap: () {
                AppStateModel().addProductToCart(product.id);
              },
              child: Stack(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AspectRatio(
                        aspectRatio: imageAspectRatio!,
                        child: imageWidget,
                      ),
                      SizedBox(
                        height: kTextBoxHeight *
                            MediaQuery.of(context).textScaleFactor,
                        width: 121,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              product.name,
                              style: theme.textTheme.labelLarge,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatter.format(product.price),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.add_shopping_cart),
                  ),
                ],
              ),
            ));

//    return ScopedModelDescendant<AppStateModel>(
//      builder: (BuildContext context, Widget child, AppStateModel model) {
//        return GestureDetector(
//          onTap: () {
//            model.addProductToCart(product.id);
//          },
//          child: child,
//        );
//      },
//      child: Stack(
//        children: <Widget>[
//          Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            crossAxisAlignment: CrossAxisAlignment.center,
//            children: <Widget>[
//              AspectRatio(
//                aspectRatio: imageAspectRatio,
//                child: imageWidget,
//              ),
//              SizedBox(
//                height: kTextBoxHeight * MediaQuery.of(context).textScaleFactor,
//                width: 121.0,
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  children: <Widget>[
//                    Text(
//                      product == null ? '' : product.name,
//                      style: theme.textTheme.button,
//                      softWrap: false,
//                      overflow: TextOverflow.ellipsis,
//                      maxLines: 1,
//                    ),
//                    const SizedBox(height: 4.0),
//                    Text(
//                      product == null ? '' : formatter.format(product.price),
//                      style: theme.textTheme.caption,
//                    ),
//                  ],
//                ),
//              ),
//            ],
//          ),
//          const Padding(
//            padding: EdgeInsets.all(16.0),
//            child: Icon(Icons.add_shopping_cart),
//          ),
//        ],
//      ),
//    );
  }
}
