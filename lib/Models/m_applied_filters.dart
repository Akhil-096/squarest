class AppliedFilter {
  final List<int> priceChoice;
  final List<int> carpetChoice;
  final int slectedIndexTownship;
  final int selectedIndexAvailableFlats;
  final int selectedIndexReadyStatus;
  List<int> selectedBuilderId;
  final List<int> bhk;

  AppliedFilter(
      {
      required this.priceChoice,
      required this.carpetChoice,
      required this.slectedIndexTownship,
      required this.selectedIndexAvailableFlats,
      required this.selectedIndexReadyStatus,
      required this.bhk,
      required this.selectedBuilderId
      });
}
