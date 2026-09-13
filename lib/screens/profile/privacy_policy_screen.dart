import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Chính sách quyền riêng tư & Điều khoản sử dụng.
///
/// Bản này soạn theo pháp luật Việt Nam (Nghị định 13/2023/NĐ-CP về bảo vệ
/// dữ liệu cá nhân, Luật An toàn thông tin mạng, Luật Bảo vệ quyền lợi người
/// tiêu dùng 2023) và có các điều khoản giới hạn trách nhiệm cho nhà phát
/// triển. Nên được luật sư Việt Nam rà soát trước khi phát hành.
const _updated = 'Cập nhật: 10/09/2026';

const List<(String, String)> _sections = [
  (
    '1. Giới thiệu',
    'An ("ứng dụng", "chúng tôi") là ứng dụng nhật ký cảm xúc và thiền do '
        'Nhà phát triển ứng dụng An – Thiền và Chữa lành phát hành. Tài liệu này gồm Chính sách quyền '
        'riêng tư và Điều khoản sử dụng. Bằng việc tạo tài khoản và sử dụng An, '
        'bạn xác nhận đã đọc, hiểu và đồng ý với toàn bộ nội dung dưới đây. Nếu '
        'không đồng ý, vui lòng ngừng sử dụng và có thể xoá tài khoản bất cứ lúc nào.',
  ),
  (
    '2. Bên kiểm soát dữ liệu',
    'Bên kiểm soát dữ liệu cá nhân là Nhà phát triển ứng dụng An – Thiền và '
        'Chữa lành. Mọi yêu cầu liên quan đến dữ liệu cá nhân xin gửi qua kênh '
        'hỗ trợ chính thức của ứng dụng, hoặc thông tin liên hệ của nhà phát '
        'triển hiển thị trên App Store / Google Play.',
  ),
  (
    '3. Dữ liệu cá nhân chúng tôi xử lý',
    'a) Dữ liệu tài khoản: địa chỉ email, tên hiển thị, mã định danh và nhà cung '
        'cấp đăng nhập (Google / Apple / Facebook), hình đại diện bạn chọn, loại '
        'gói dịch vụ.\n'
        'b) Nội dung bạn tạo: cảm xúc, mức độ, chủ đề và ghi chú trong mỗi lần '
        'ghi nhận; thời lượng và thời điểm các buổi thiền/thở.\n'
        'c) Dữ liệu kỹ thuật tối thiểu để vận hành: nhật ký lỗi ẩn danh, múi giờ '
        'thiết bị (để hẹn giờ nhắc). An không thu thập danh bạ, vị trí, ảnh, '
        'hay dữ liệu từ ứng dụng khác.',
  ),
  (
    '4. Mục đích xử lý',
    'Cung cấp và duy trì tính năng ghi nhận cảm xúc, thống kê, chuỗi ngày và '
        'gợi ý bài thiền; đồng bộ dữ liệu của bạn giữa các thiết bị; gửi nhắc '
        'nhở trong ứng dụng theo lịch bạn cho phép; xử lý đăng ký gói trả phí; '
        'bảo đảm an toàn, phát hiện lạm dụng và khắc phục sự cố; tuân thủ nghĩa '
        'vụ pháp lý.',
  ),
  (
    '5. Cơ sở pháp lý',
    'Chúng tôi xử lý dữ liệu cá nhân của bạn trên cơ sở sự đồng ý mà bạn thể '
        'hiện khi tạo tài khoản và sử dụng ứng dụng, và để thực hiện thoả thuận '
        'cung cấp dịch vụ giữa bạn và chúng tôi. Bạn có quyền rút lại sự đồng ý '
        'bất cứ lúc nào (xem mục 9); việc rút lại không ảnh hưởng đến tính hợp '
        'pháp của việc xử lý trước đó.',
  ),
  (
    '6. Lưu trữ và bên xử lý',
    'Dữ liệu được lưu: (i) trên thiết bị của bạn để dùng nhanh và ngoại tuyến, '
        'và (ii) trên máy chủ do chúng tôi vận hành cùng các nhà cung cấp hạ '
        'tầng. Chúng tôi sử dụng Google Firebase Authentication để xác thực đăng '
        'nhập và dịch vụ máy chủ/điện toán đám mây để lưu trữ. Một phần hạ tầng '
        'của các nhà cung cấp này có thể đặt ngoài lãnh thổ Việt Nam; khi đó '
        'việc chuyển dữ liệu ra nước ngoài được thực hiện phù hợp với Nghị định '
        '13/2023/NĐ-CP. Thanh toán gói trả phí do Apple App Store hoặc Google '
        'Play xử lý; chúng tôi không nhận hay lưu thông tin thẻ của bạn.',
  ),
  (
    '7. Chia sẻ dữ liệu',
    'Chúng tôi KHÔNG bán dữ liệu cá nhân, KHÔNG dùng nội dung nhật ký của bạn '
        'để quảng cáo, và KHÔNG chia sẻ cho bên thứ ba vì mục đích tiếp thị. '
        'Dữ liệu chỉ được chia sẻ với: các nhà cung cấp hạ tầng nêu ở mục 6 '
        '(trong phạm vi cần thiết để vận hành); cơ quan nhà nước có thẩm quyền '
        'khi có yêu cầu hợp pháp; hoặc bên nhận chuyển giao trong trường hợp '
        'sáp nhập, mua bán doanh nghiệp (bạn sẽ được thông báo).',
  ),
  (
    '8. Thời gian lưu trữ',
    'Dữ liệu tài khoản và nội dung của bạn được lưu trong suốt thời gian tài '
        'khoản còn hoạt động. Khi bạn xoá tài khoản, toàn bộ dữ liệu trên máy '
        'chủ được xoá ngay; bản sao lưu kỹ thuật (nếu có) được xoá trong vòng '
        'tối đa 90 ngày. Dữ liệu trên thiết bị bị xoá khi bạn xoá tài khoản '
        'hoặc gỡ ứng dụng.',
  ),
  (
    '9. Quyền của bạn',
    'Theo pháp luật Việt Nam, bạn có quyền: được biết và đồng ý về việc xử lý; '
        'truy cập, xem và yêu cầu chỉnh sửa dữ liệu; rút lại sự đồng ý; xoá dữ '
        'liệu; hạn chế hoặc phản đối việc xử lý; yêu cầu cung cấp dữ liệu; khiếu '
        'nại, tố cáo hoặc khởi kiện; và yêu cầu bồi thường thiệt hại theo quy '
        'định. Để thực hiện, bạn có thể dùng chức năng "Xoá tài khoản" trong '
        'ứng dụng, hoặc gửi yêu cầu qua kênh hỗ trợ chính thức của ứng dụng; '
        'chúng tôi phản hồi '
        'trong thời hạn luật định (thường là 72 giờ với yêu cầu khẩn và tối đa '
        '30 ngày với các yêu cầu khác). Cơ quan có thẩm quyền tiếp nhận khiếu '
        'nại: Cục An ninh mạng và phòng, chống tội phạm sử dụng công nghệ cao '
        '(A05) - Bộ Công an.',
  ),
  (
    '10. Trẻ em',
    'An không dành cho người dưới 16 tuổi. Nếu bạn dưới 16 tuổi, chỉ được sử '
        'dụng khi có sự đồng ý của cha, mẹ hoặc người giám hộ. Nếu phát hiện đã '
        'thu thập dữ liệu của trẻ em không đúng quy định, chúng tôi sẽ xoá ngay '
        'khi được thông báo.',
  ),
  (
    '11. Bảo mật',
    'Chúng tôi áp dụng các biện pháp kỹ thuật và quản lý hợp lý: mã hoá đường '
        'truyền, xác thực qua nhà cung cấp uy tín, phân quyền truy cập, tuỳ '
        'chọn khoá ứng dụng bằng sinh trắc học trên thiết bị. Tuy nhiên không '
        'hệ thống nào an toàn tuyệt đối; bạn có trách nhiệm giữ an toàn tài '
        'khoản đăng nhập của mình.',
  ),
  (
    '12. Bản chất của dịch vụ — Không phải tư vấn y tế',
    'An là công cụ tự chăm sóc tinh thần và thư giãn. An KHÔNG phải là dịch vụ '
        'khám, chữa bệnh, không phải tư vấn tâm lý, tâm thần hay y tế, và KHÔNG '
        'thay thế cho việc thăm khám, chẩn đoán hoặc điều trị của chuyên gia có '
        'chuyên môn. Nội dung trong ứng dụng (bài thiền, câu chữ của "Mây", gợi '
        'ý) chỉ mang tính tham khảo và hỗ trợ thư giãn, không bảo đảm bất kỳ '
        'kết quả nào. Bạn nên tham vấn bác sĩ hoặc chuyên gia sức khoẻ tâm thần '
        'cho mọi vấn đề liên quan đến sức khoẻ.',
  ),
  (
    '13. Tình huống khẩn cấp',
    'An không giám sát dữ liệu của bạn theo thời gian thực và không thể can '
        'thiệp khi bạn gặp khủng hoảng. Nếu bạn hoặc người khác đang gặp nguy '
        'hiểm hoặc có ý định tự làm hại bản thân, hãy gọi ngay 115, đến cơ sở y '
        'tế gần nhất, hoặc liên hệ đường dây hỗ trợ khủng hoảng tâm lý. An '
        'không chịu trách nhiệm cho hậu quả phát sinh từ việc người dùng dựa '
        'vào ứng dụng thay cho hỗ trợ chuyên môn hoặc cấp cứu.',
  ),
  (
    '14. Trách nhiệm của người dùng',
    'Bạn tự chịu trách nhiệm về các quyết định và hành động của mình liên quan '
        'đến sức khoẻ, cảm xúc và đời sống, dù có hay không sử dụng An. Bạn cam '
        'kết cung cấp thông tin đăng nhập trung thực, không sử dụng ứng dụng '
        'vào mục đích trái pháp luật, và không can thiệp, phá hoại hệ thống.',
  ),
  (
    '15. Giới hạn trách nhiệm',
    'Trong phạm vi pháp luật cho phép: An được cung cấp "như hiện có" và "theo '
        'khả năng sẵn có", không kèm bảo đảm rằng ứng dụng sẽ không gián đoạn, '
        'không lỗi hoặc đáp ứng mọi kỳ vọng của bạn. Nhà phát triển không chịu '
        'trách nhiệm cho các thiệt hại gián tiếp, ngẫu nhiên, đặc biệt hoặc mang '
        'tính hệ quả, mất dữ liệu, mất lợi nhuận hay tổn thất tinh thần phát '
        'sinh từ việc sử dụng hoặc không thể sử dụng ứng dụng. Tổng trách nhiệm '
        'của nhà phát triển đối với bạn, nếu có, không vượt quá tổng số tiền bạn '
        'đã thực trả cho An trong 12 tháng liền trước sự kiện phát sinh trách '
        'nhiệm. Quy định này không loại trừ trách nhiệm mà pháp luật không cho '
        'phép loại trừ.',
  ),
  (
    '16. Gói trả phí, thanh toán và giá',
    'Gói Premium được bán và thanh toán qua Apple App Store hoặc Google Play và '
        'tuân theo điều khoản của các nền tảng này. GIÁ CÓ THỂ THAY ĐỔI BẤT CỨ '
        'LÚC NÀO MÀ KHÔNG CẦN THÔNG BÁO TRƯỚC. Tuy nhiên, nếu bạn đang có gói '
        'trả phí còn hiệu lực, mức giá của gói hiện tại được giữ nguyên cho đến '
        'khi bạn huỷ gia hạn hoặc gói hết hạn; thay đổi giá chỉ áp dụng cho lần '
        'đăng ký hoặc gia hạn sau đó, và với gói tự động gia hạn, việc tăng giá '
        'sẽ được thông báo theo quy định của nền tảng trước khi có hiệu lực. '
        'Gói tự động gia hạn cho đến khi bạn tắt gia hạn trong App Store / '
        'Google Play. Hoàn tiền (nếu có) do App Store / Google Play quyết định '
        'theo chính sách của họ. Xoá tài khoản trong An KHÔNG tự động huỷ gói '
        'và KHÔNG hoàn tiền — bạn phải huỷ riêng trong App Store / Google Play.',
  ),
  (
    '17. Thay đổi và ngừng dịch vụ',
    'Nhà phát triển có quyền chỉnh sửa, thêm, tạm ngừng hoặc chấm dứt bất kỳ '
        'tính năng nào của An, hoặc ngừng toàn bộ dịch vụ, vào bất cứ lúc nào. '
        'Với thay đổi lớn ảnh hưởng đến quyền lợi người dùng trả phí, chúng tôi '
        'sẽ nỗ lực thông báo trước một cách hợp lý.',
  ),
  (
    '18. Sở hữu trí tuệ',
    'Toàn bộ bài thiền, âm thanh, văn bản, hình ảnh, thương hiệu và thiết kế '
        'của An thuộc quyền sở hữu của nhà phát triển hoặc bên cấp phép, được '
        'bảo hộ theo pháp luật. Bạn không được sao chép, phân phối hay khai '
        'thác thương mại khi chưa có sự đồng ý bằng văn bản. Nội dung nhật ký do '
        'bạn viết thuộc về bạn; bạn cấp cho chúng tôi quyền cần thiết để lưu '
        'trữ và hiển thị lại nội dung đó cho chính bạn.',
  ),
  (
    '19. Bất khả kháng',
    'Nhà phát triển không chịu trách nhiệm cho việc chậm trễ hoặc không thực '
        'hiện được nghĩa vụ do sự kiện nằm ngoài tầm kiểm soát hợp lý: thiên '
        'tai, dịch bệnh, sự cố hạ tầng viễn thông hoặc nhà cung cấp bên thứ ba, '
        'thay đổi pháp luật, hành vi của cơ quan nhà nước.',
  ),
  (
    '20. Luật áp dụng và giải quyết tranh chấp',
    'Tài liệu này được điều chỉnh bởi pháp luật Việt Nam. Mọi tranh chấp phát '
        'sinh sẽ được ưu tiên giải quyết thông qua thương lượng, hoà giải; nếu '
        'không đạt được thoả thuận, tranh chấp sẽ được đưa ra Toà án nhân dân '
        'có thẩm quyền tại Việt Nam.',
  ),
  (
    '21. Thay đổi chính sách',
    'Chúng tôi có thể cập nhật tài liệu này. Bản mới có hiệu lực kể từ khi được '
        'đăng trong ứng dụng; ngày cập nhật hiển thị ở đầu trang. Việc bạn tiếp '
        'tục sử dụng An sau khi cập nhật đồng nghĩa với việc chấp nhận bản mới.',
  ),
  (
    '22. Liên hệ',
    'Mọi câu hỏi về quyền riêng tư hoặc điều khoản, xin liên hệ qua kênh hỗ '
        'trợ chính thức của ứng dụng, hoặc thông tin nhà phát triển trên App '
        'Store / Google Play.',
  ),
];

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text('Quay lại', style: TextStyle(fontFamily: 'BeVietnamPro', fontSize: 14, color: AppColors.ink.withValues(alpha: 0.5))),
              ),
              const SizedBox(height: 22),
              const Text('Chính sách quyền riêng tư\nvà Điều khoản sử dụng',
                  style: TextStyle(fontFamily: 'Lora', fontSize: 24, height: 32 / 24, color: AppColors.ink)),
              const SizedBox(height: 8),
              Text(_updated, style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 12.5, color: AppColors.ink.withValues(alpha: 0.5))),
              const SizedBox(height: 22),
              for (final (heading, body) in _sections) ...[
                Text(heading, style: const TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.ink)),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: TextStyle(fontFamily: 'BeVietnamPro', fontWeight: FontWeight.w300, fontSize: 13.5, height: 22 / 13.5, color: AppColors.ink.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
