import 'package:flutter/material.dart';
import 'package:nutripro_1/presentation/widgets/net_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecipeDetailPage extends StatefulWidget {
  final String id, name, imageUrl;
  const RecipeDetailPage({
    super.key,
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  @override
  void didChangeDependencies() {
    precacheImage(CachedNetworkImageProvider(widget.imageUrl), context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: Center(
        child: NetImage(
          widget.imageUrl,
          width: w,
          height: w,
          fit: BoxFit.contain,
          heroTag: widget.id,
        ),
      ),
    );
  }
}
