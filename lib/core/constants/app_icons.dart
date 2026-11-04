import 'package:hugeicons/hugeicons.dart';

/// Re-exported so a widget that draws an icon imports this file only, the
/// same way it would import `material.dart` for `Icon`.
export 'package:hugeicons/hugeicons.dart' show HugeIcon;

/// Every glyph the app draws from code, named for what it means rather than
/// for the icon set it comes from.
///
/// The app uses Hugeicons throughout; Material's `Icons` are not mixed in,
/// so a checkmark in a dialog and a checkmark on a cart line are the same
/// drawing at the same weight. Picking a different set later, or swapping
/// one glyph for a better match, happens here and nowhere else.
///
/// Hugeicons ships its glyphs as data, not as a font, so an icon is an
/// [AppIconData] passed to `HugeIcon(icon: ...)` — not an `IconData` passed
/// to `Icon(...)`. Widgets that take an icon as a parameter type it as
/// [AppIconData] for the same reason.
typedef AppIconData = List<List<dynamic>>;

abstract final class AppIcons {
  // ------------------------------------------------------------ actions --
  static const AppIconData check = HugeIcons.strokeRoundedTick02;
  static const AppIconData checkCircle =
      HugeIcons.strokeRoundedCheckmarkCircle02;
  static const AppIconData close = HugeIcons.strokeRoundedCancel01;
  static const AppIconData add = HugeIcons.strokeRoundedAdd01;
  static const AppIconData minus = HugeIcons.strokeRoundedMinusSign;
  static const AppIconData delete = HugeIcons.strokeRoundedDelete02;
  static const AppIconData edit = HugeIcons.strokeRoundedEdit02;
  static const AppIconData receipt = HugeIcons.strokeRoundedInvoice01;
  static const AppIconData truck = HugeIcons.strokeRoundedDeliveryTruck01;
  static const AppIconData parcel = HugeIcons.strokeRoundedPackage;
  static const AppIconData refresh = HugeIcons.strokeRoundedRefresh;
  static const AppIconData copy = HugeIcons.strokeRoundedCopy01;

  // --------------------------------------------------------- navigation --
  static const AppIconData chevronRight = HugeIcons.strokeRoundedArrowRight01;
  static const AppIconData chevronDown = HugeIcons.strokeRoundedArrowDown01;
  static const AppIconData back = HugeIcons.strokeRoundedArrowLeft01;

  // ------------------------------------------------------------ address --
  static const AppIconData home = HugeIcons.strokeRoundedHome01;
  static const AppIconData work = HugeIcons.strokeRoundedBriefcase01;
  static const AppIconData location = HugeIcons.strokeRoundedLocation01;
  static const AppIconData currentLocation = HugeIcons.strokeRoundedNavigation2;
  static const AppIconData mapPin = HugeIcons.strokeRoundedLocation01;
  static const AppIconData information =
      HugeIcons.strokeRoundedInformationCircle;

  /// Leaves the app — the socials, WhatsApp, the dialler.
  static const AppIconData external = HugeIcons.strokeRoundedArrowUpRight01;

  /// A row whose value is chosen from a list.
  static const AppIconData unfold = HugeIcons.strokeRoundedArrowUpDown;

  // ------------------------------------------------------------- search --
  static const AppIconData search = HugeIcons.strokeRoundedSearch01;
  static const AppIconData searchEmpty = HugeIcons.strokeRoundedSearchRemove;
  static const AppIconData filterOff = HugeIcons.strokeRoundedFilterRemove;
  static const AppIconData filter = HugeIcons.strokeRoundedFilterHorizontal;
  static const AppIconData sort = HugeIcons.strokeRoundedArrowUpDown;

  // ------------------------------------------------------------ catalog --
  static const AppIconData cart = HugeIcons.strokeRoundedShoppingBag02;
  static const AppIconData favorite = HugeIcons.strokeRoundedFavourite;
  static const AppIconData share = HugeIcons.strokeRoundedShare08;
  static const AppIconData star = HugeIcons.strokeRoundedStar;

  // ------------------------------------------------------------ account --
  static const AppIconData user = HugeIcons.strokeRoundedUser;
  static const AppIconData notification = HugeIcons.strokeRoundedNotification02;
  static const AppIconData camera = HugeIcons.strokeRoundedCamera01;
  static const AppIconData gallery = HugeIcons.strokeRoundedAlbum02;
  static const AppIconData support = HugeIcons.strokeRoundedCustomerService01;

  // ------------------------------------------------------ visual search --
  static const AppIconData cameraOff = HugeIcons.strokeRoundedCameraOff01;
  static const AppIconData cameraFlip = HugeIcons.strokeRoundedCameraRotated01;
  static const AppIconData flashOn = HugeIcons.strokeRoundedFlash;
  static const AppIconData flashOff = HugeIcons.strokeRoundedFlashOff;

  // -------------------------------------------------------------- state --
  static const AppIconData empty = HugeIcons.strokeRoundedInbox;
  static const AppIconData error = HugeIcons.strokeRoundedAlertCircle;
  static const AppIconData help = HugeIcons.strokeRoundedHelpCircle;

  /// Stands in for a photo that has not loaded, or was never supplied.
  static const AppIconData image = HugeIcons.strokeRoundedImage02;
}
