import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_core/localizations.dart';

class SfLocalizationsFr extends SfLocalizations {
  SfLocalizationsFr();

  @override
  String get noSelectedDateCalendarLabel => 'Pas de date sélectionnée';

  @override
  String get noEventsCalendarLabel => 'Pas d\'évenement';

  @override
  String get daySpanCountLabel => 'Jour';

  @override
  String get allowedViewDayLabel => 'Jour';

  @override
  String get allowedViewWeekLabel => 'Semaine';

  @override
  String get allowedViewWorkWeekLabel => 'Semaine';

  @override
  String get allowedViewMonthLabel => 'Mois';

  @override
  String get allowedViewScheduleLabel => 'Calendrier';

  @override
  String get allowedViewTimelineDayLabel => 'Calendrier du jour';

  @override
  String get allowedViewTimelineWeekLabel => 'Calendrier de la semaine';

  @override
  String get allowedViewTimelineWorkWeekLabel => 'Calendrier de la semaine';

  @override
  String get allowedViewTimelineMonthLabel => 'Calendrier du mois';

  @override
  String get todayLabel => 'Aujourd\'hui';

  @override
  String get muharramLabel => 'Muharram';

  @override
  String get safarLabel => 'Safar';

  @override
  String get rabi1Label => 'Rabi\' al-awwal';

  @override
  String get rabi2Label => 'Rabi\' al-thani';

  @override
  String get jumada1Label => 'Jumada al-awwal';

  @override
  String get jumada2Label => 'Jumada al-thani';

  @override
  String get rajabLabel => 'Rajab';

  @override
  String get shaabanLabel => 'Sha\'aban';

  @override
  String get ramadanLabel => 'Ramadan';

  @override
  String get shawwalLabel => 'Shawwal';

  @override
  String get dhualqiLabel => 'Dhu al-Qi\'dah';

  @override
  String get dhualhiLabel => 'Dhu al-Hijjah';

  @override
  String get shortMuharramLabel => 'Muh.';

  @override
  String get shortSafarLabel => 'Saf.';

  @override
  String get shortRabi1Label => 'Rabi. I';

  @override
  String get shortRabi2Label => 'Rabi. II';

  @override
  String get shortJumada1Label => 'Jum. I';

  @override
  String get shortJumada2Label => 'Jum. II';

  @override
  String get shortRajabLabel => 'Raj.';

  @override
  String get shortShaabanLabel => 'Sha.';

  @override
  String get shortRamadanLabel => 'Ram.';

  @override
  String get shortShawwalLabel => 'Shaw.';

  @override
  String get shortDhualqiLabel => 'Dhu\'l-Q';

  @override
  String get shortDhualhiLabel => 'Dhu\'l-H';

  @override
  String get ofDataPagerLabel => 'of';

  @override
  String get pagesDataPagerLabel => 'pages';

  @override
  String get pdfBookmarksLabel => 'Bookmarks';

  @override
  String get pdfNoBookmarksLabel => 'No bookmarks found';

  @override
  String get pdfScrollStatusOfLabel => 'of';

  @override
  String get pdfGoToPageLabel => 'Go to page';

  @override
  String get pdfEnterPageNumberLabel => 'Enter page number';

  @override
  String get pdfInvalidPageNumberLabel => 'Please enter a valid number';

  @override
  String get pdfPaginationDialogOkLabel => 'Ok';

  @override
  String get pdfPaginationDialogCancelLabel => 'Annuler';

  String get weeknumberLabel => 'Semaine';
}

class SfLocalizationsFrDelegate extends LocalizationsDelegate<SfLocalizations> {
  const SfLocalizationsFrDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'fr';

  @override
  Future<SfLocalizations> load(Locale locale) {
    return SynchronousFuture<SfLocalizations>(SfLocalizationsFr());
  }

  @override
  bool shouldReload(LocalizationsDelegate<SfLocalizations> old) => true;
}
