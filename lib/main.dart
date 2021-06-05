import 'package:ElazizSepetiPostMaker/application/my_banner.dart';
import 'package:ElazizSepetiPostMaker/application/post_creator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ElazizSepetiPostMaker/extensions/widget_ext.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  final List<MyBanner> banners = [
    MyBanner(label: "Hiçbiri", type: BannerType.none),
    MyBanner(
      label: "Kiralandı",
      type: BannerType.rented,
      bannerImagePath: "images/banner_blue.png",
    ),
    MyBanner(
      label: "Satıldı",
      type: BannerType.soldOut,
      bannerImagePath: "images/banner_orange.png",
    ),
    MyBanner(
      label: "Kat Karşılığı",
      type: BannerType.forFloor,
      bannerImagePath: "images/banner_purple.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Fmd Emlak - Şablon Oluşturucu',
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.grey[800],
          appBarTheme: AppBarTheme(
              color: Colors.amber, textTheme: Theme.of(context).textTheme),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Fmd Emlak - Şablon Oluşturucu'),
          ),
          body: MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (_) => PostCreator(),
              ),
            ],
            child: Consumer<PostCreator>(
              builder: (context, state, widget) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (state.imageByteData == null && !state.isGeneratingImage)
                    Center(
                      child: const SizedBox(
                        width: 300.0,
                        height: 300.0,
                        child: Center(
                          child: Text('Resim yükleyin'),
                        ),
                      ).top(30).bottom(10),
                    )
                  else if (state.imageByteData == null &&
                      state.isGeneratingImage)
                    Center(
                      child: const SizedBox(
                        width: 300.0,
                        height: 300.0,
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.amber),
                          ),
                        ),
                      ).top(30).bottom(10),
                    )
                  else
                    Center(
                      child: Image.memory(
                        state.imageByteData.buffer.asUint8List(),
                        width: 300.0,
                        height: 300.0,
                      ).top(30).bottom(10.0),
                    ),
                  const Center(
                    child: ImageOptions(),
                  ),
                  const Divider().top(10.0).bottom(10.0),
                  const Text(
                    "Bant tipleri",
                    style: TextStyle(fontSize: 16),
                  ).left(30).bottom(10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Column(
                          children: banners
                              .getRange(0, 2)
                              .map((banner) =>
                                  bannerToListTile(banner, state, context))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: banners
                              .getRange(2, 4)
                              .map((banner) =>
                                  bannerToListTile(banner, state, context))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .85,
                      child: RaisedButton(
                        color: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        onPressed: () => state.imageByteData != null
                            ? Provider.of<PostCreator>(context, listen: false)
                                .saveImage()
                            : null,
                        child: const Text(
                          'Kaydet',
                          style: TextStyle(color: Colors.amber),
                        ),
                      ),
                    ).bottom(10),
                  ),
                  if (!state.isSaved)
                    const Center()
                  else
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 300,
                          child: Row(
                            children: const <Widget>[
                              Icon(
                                Icons.check,
                                color: Colors.green,
                                size: 40,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                'Başarıyla kaydedildi',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ).left(10).right(10),
            ),
          ),
        ));
  }

  ListTile bannerToListTile(
      MyBanner banner, PostCreator state, BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(banner.label,
          style: const TextStyle(color: Colors.white, fontSize: 16)),
      leading: Radio(
        activeColor: Colors.amber,
        value: banner,
        groupValue: state.banner,
        onChanged: (MyBanner banner) {
          Provider.of<PostCreator>(context, listen: false)
              .changeSelectedBanner(banner);
        },
      ),
    );
  }
}

class ImageOptions extends StatelessWidget {
  const ImageOptions({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SelectImageButton(
          text: "Kamerayla Çek",
          iconData: Icons.camera_alt,
          source: ImageSource.camera,
        ).right(12.0),
        const SelectImageButton(
          text: "Galeriden Yükle",
          iconData: Icons.image,
          source: ImageSource.gallery,
        ).right(12.0),
      ],
    );
  }
}

class SelectImageButton extends StatelessWidget {
  const SelectImageButton({
    Key key,
    this.source,
    this.iconData,
    this.text,
  }) : super(key: key);

  final ImageSource source;
  final IconData iconData;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () =>
          Provider.of<PostCreator>(context, listen: false).selectImage(source),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      color: Colors.redAccent,
      child: Row(
        children: <Widget>[
          Icon(iconData, color: Colors.white),
          const SizedBox(width: 5.0),
          Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
