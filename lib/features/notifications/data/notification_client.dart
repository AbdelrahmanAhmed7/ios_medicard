import 'package:dio/dio.dart';
import 'package:medicard/features/notifications/data/model/notification_model.dart';
import 'package:medicard/features/notifications/data/model/api_response.dart';
import 'package:retrofit/retrofit.dart';

part 'notification_client.g.dart';

@RestApi(baseUrl: 'https://medicard-api-v2.medicardeg.com/api/')
abstract class NotificationClient {
  factory NotificationClient(Dio dio, {String baseUrl}) = _NotificationClient;

  @GET("Notification")
  Future<ApiResponse<NotificationData>> getNotifications(
    @Header("Authorization") String token,
    @Query("pageNumber") int pageNumber,
    @Query("pageSize") int pageSize,
  );

  @POST("Notification/send")
  Future<ApiResponse<dynamic>> sendNotification(
    @Header("Authorization") String token,
    @Body() Map<String, dynamic> body,
  );

  @POST("Notification/{id}/read")
  Future<ApiResponse<dynamic>> markAsRead(
    @Header("Authorization") String token,
    @Path("id") int id,
  );

  @POST("Notification/read-all")
  Future<ApiResponse<dynamic>> markAllAsRead(
    @Header("Authorization") String token,
  );
}
