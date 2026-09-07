import '../../state/app_state.dart';

String planLabel(PlanTier plan) => switch (plan) {
      PlanTier.free => 'An Free',
      PlanTier.monthly => 'An Premium · theo tháng',
      PlanTier.yearly => 'An Premium · theo năm',
    };
