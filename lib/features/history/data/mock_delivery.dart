import '../models/delivery_model.dart';

class MockDeliveryData {
  MockDeliveryData._();

  static List<DeliveryModel> get deliveries => const [
        DeliveryModel(
          id: '1',
          orderNo: 'TB504321-5598',
          pickup: 'บ้าน',
          destination: 'ชลบุรี',
          date: '20 มิ.ย. 2569',
          time: '14.00 น.',
          price: 1290.00,
          status: DeliveryStatus.inProgress,
          isHistoryOnly: false,
        ),
        DeliveryModel(
          id: '2',
          orderNo: 'TB592488-2621',
          pickup: 'เก้ากิโล 5',
          destination: 'หน้าศาลนครศรีฯ',
          date: '18 มิ.ย. 2569',
          time: '11.00 น.',
          price: 250.00,
          status: DeliveryStatus.cancelled,
          isHistoryOnly: true,
        ),
        DeliveryModel(
          id: '3',
          orderNo: 'TB595688-2621',
          pickup: 'เก้ากิโล',
          destination: 'บางพระ',
          date: '15 มิ.ย. 2569',
          time: '11.00 น.',
          price: 542.00,
          status: DeliveryStatus.completed,
          isHistoryOnly: true,
        ),
        DeliveryModel(
          id: '4',
          orderNo: 'TB595688-2321',
          pickup: 'สุรศักดิ์ 2',
          destination: 'สุรศักดิ์ 11',
          date: '12 มิ.ย. 2569',
          time: '15.00 น.',
          price: 300.00,
          status: DeliveryStatus.inProgress,
          isHistoryOnly: false,
        ),
        DeliveryModel(
          id: '5',
          orderNo: 'TB506331-3622',
          pickup: 'พัทยา 77',
          destination: 'พัทยา 12',
          date: '10 มิ.ย. 2569',
          time: '09.30 น.',
          price: 850.00,
          status: DeliveryStatus.completed,
          isHistoryOnly: true,
        ),
      ];
}
