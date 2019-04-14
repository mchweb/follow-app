class MessageModel {
  final bool isIncoming;
  final String text;
  final String time;

  MessageModel({this.isIncoming, this.text, this.time});
}

List<MessageModel> dummyData = [
  new MessageModel(
    isIncoming: true,
    text: "Вот так даже почти похоже на реальный диалог",
    time: "15:41"
  ),
  new MessageModel(
    isIncoming: false,
    text: "и ещё одно короткое",
    time: "15:40"
  ),
  new MessageModel(
    isIncoming: false,
    text: "теперь длинное сообщение с этой стороны",
    time: "15:40"
  ),
  new MessageModel(
    isIncoming: true,
    text: "и надо ещё какое-нибудь длинное сообщение в несколько строк, чтобы это всё красиво выглядело",
    time: "15:38"
  ),
  new MessageModel(
    isIncoming: true,
    text: "хватит, блять, нервничать",
    time: "15:35"
  ),
  new MessageModel(
    isIncoming: false,
    text: "а что если какули не выходят?",
    time: "15:30"
  ),
];
