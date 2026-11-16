import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tam_customer/app/app.dart';
import 'package:tam_customer/app/router/app_routes.dart';
import 'package:tam_customer/core/config/feature_data_mode.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/address_editor_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/bloc/addresses_cubit.dart';
import 'package:tam_customer/features/addresses/presentation/pages/address_editor_page.dart';
import 'package:tam_customer/features/addresses/presentation/pages/addresses_page.dart';
import 'package:tam_customer/features/auth/data/memory_auth_session_store.dart';
import 'package:tam_customer/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tam_customer/features/home/presentation/pages/home_page.dart';
import 'package:tam_customer/features/ride_request/presentation/bloc/ride_draft_bloc.dart';
import 'package:tam_customer/features/ride_request/presentation/pages/ride_request_page.dart';
import 'package:tam_customer/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:tam_customer/features/settings/presentation/pages/settings_page.dart';
import '../support/fake_auth_repository.dart';
import 'support/customer_app_harness.dart';

void main() {
  testWidgets(
    'CRUD integrates with saved pickup/destination and resets on logout',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      await tester.tap(find.byKey(const Key('home-addresses')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('إضافة موقع'));
      await tester.tap(find.text('إضافة موقع'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('address-name')),
        'عنوان للاختبار',
      );
      await tester.tap(find.byKey(const Key('address-choose-location')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('address-location-search')),
        'الأمويين',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('ساحة الأمويين'));
      await tester.pumpAndSettle();
      final editor = tester
          .element(find.byType(AddressEditorPage))
          .read<AddressEditorCubit>();
      await tester.ensureVisible(find.byKey(const Key('address-save')));
      await tester.tap(find.byKey(const Key('address-save')));
      await tester.pumpAndSettle();
      expect(find.byType(AddressesPage), findsOneWidget);
      final created = editor.state.original!;
      expect(
        tester
            .element(find.byType(AddressesPage))
            .read<AddressesCubit>()
            .state
            .items,
        hasLength(3),
      );
      await showCustomerHome(tester, router);

      await tester.ensureVisible(
        find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة'),
      );
      await tester.tap(find.text('حدد نقطة الانطلاق والوجهة لطلب رحلة'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حدد مكان الانطلاق'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ride-saved-addresses')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('saved-address-address-home-001')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('إلى أين تريد الذهاب؟'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('ride-saved-addresses')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('saved-address-${created.id}')));
      await tester.pumpAndSettle();
      final draft = tester
          .element(find.byType(RideRequestPage))
          .read<RideDraftBloc>();
      expect(draft.state.destination, created.input.location);
      expect(draft.state.quote, isNotNull);
      final previousQuote = draft.state.quote!;

      // A saved address is a location snapshot, never a mutable trip reference.
      router.push(AppRoutes.addresses);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('address-menu-${created.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('address-delete-${created.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('حذف'));
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(draft.state.destination, created.input.location);
      expect(draft.state.quote, previousQuote);

      await showCustomerHome(tester, router);
      await customerAuth(tester).logout();
      await tester.pumpAndSettle();
      await enterCustomerSession(tester);
      router.go(AppRoutes.addresses);
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(AddressesPage))
            .read<AddressesCubit>()
            .state
            .items
            .map((a) => a.id),
        ['address-home-001', 'address-work-001'],
      );
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Settings link respects unsaved changes and editor route identity',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      router.push(AppRoutes.settings);
      await tester.pumpAndSettle();
      final settings = tester
          .element(find.byType(SettingsPage))
          .read<SettingsCubit>();
      settings.nameChanged('Unsaved Name');
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-addresses')),
        180,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('settings-content')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byKey(const Key('settings-addresses')));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('تجاهل التغييرات'));
      await tester.pumpAndSettle();
      expect(find.byType(AddressesPage), findsOneWidget);
      expect(settings.state.hasUnsavedChanges, false);
      await tester.tap(find.byKey(const Key('address-menu-address-home-001')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address-edit-address-home-001')));
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(AddressEditorPage))
            .read<AddressEditorCubit>()
            .id,
        'address-home-001',
      );
      router.go(AppRoutes.addressEditLocation('address-work-001'));
      await tester.pumpAndSettle();
      expect(
        tester
            .element(find.byType(AddressEditorPage))
            .read<AddressEditorCubit>()
            .id,
        'address-work-001',
      );
      expect(find.text('العمل'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'address editor asks before discarding and persists only confirmed edits',
    (tester) async {
      await launchCustomerApp(tester);
      await enterCustomerSession(tester);
      final router = customerRouter(tester);
      router.push(AppRoutes.addresses);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address-menu-address-home-001')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address-edit-address-home-001')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('address-name')),
        'تعديل غير محفوظ',
      );
      await tester.tap(find.byType(BackButtonIcon));
      await tester.pumpAndSettle();
      await tester.tap(find.text('متابعة التعديل'));
      await tester.pumpAndSettle();
      expect(find.text('تعديل غير محفوظ'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('address-save')));
      await tester.tap(find.byKey(const Key('address-save')));
      await tester.pumpAndSettle();
      expect(find.text('تعديل غير محفوظ'), findsOneWidget);
      expect(
        tester
            .element(find.byType(AddressesPage))
            .read<AddressesCubit>()
            .state
            .items
            .first
            .input
            .name,
        'تعديل غير محفوظ',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  for (final guest in [false, true]) {
    testWidgets(
      'API addresses stay protected during ${guest ? 'guest' : 'local'} mock booking',
      (tester) async {
        await tester.pumpWidget(
          TamApp(
            authRepository: FakeAuthRepository(latency: Duration.zero),
            sessionStore: MemoryAuthSessionStore(),
            temporaryPhoneEntryEnabled: true,
            dataModes: const FeatureDataModes(
              overrides: {CustomerFeature.addresses: FeatureDataMode.api},
            ),
          ),
        );
        await tester.pumpAndSettle();
        await enterCustomerSession(tester, phone: guest ? null : '0941234567');
        final router = customerRouter(tester);
        final auth = customerAuth(tester);
        for (final path in [
          AppRoutes.addresses,
          AppRoutes.addAddress,
          AppRoutes.addressEditLocation('address-home-001'),
        ]) {
          router.go(path);
          await tester.pumpAndSettle();
          expect(find.byType(HomePage), findsOneWidget);
          expect(find.byType(AddressesPage), findsNothing);
        }
        expect(
          auth.state.status,
          guest ? AuthStatus.guest : AuthStatus.localAccess,
        );
        expect(auth.state.user, isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
