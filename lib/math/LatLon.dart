import "package:ella/math/Math.dart";
import "package:ella/exception/IllegalArgumentException.dart";
import "package:ella/marshal/ISerialisable.dart";
import "package:ella/marshal/MarshalledObject.dart";

/** @fileoverview An instance of this class represents a pair of geodetic coordinates (lat/lon). */

class LatLon implements ISerialisable
{
  static final double RADII_KM = 6371.0;

  /** The latitude. */
  late double lat;

  /** The longitude. */
  late double lon;

  /** Generative constructor */
  LatLon(double lat, double lon)
  {
    if ( !isValidLat(lat) ) {
      throw new IllegalArgumentException("Invalid lat value, got ${lat}");
    }
    if ( !isValidLon(lon) ) {
      throw new IllegalArgumentException("Invalid lon value, got ${lon}");
    }

    this.lat = lat;
    this.lon = lon;
  }

  /** true if [lat] is a valid latitude in the range -90..90 */
  static bool isValidLat(double lat)
  {
    return lat >= -90 && lat <= 90;
  }

  /** true if [lon] is a valid longitude in the range -180..180 */
  static bool isValidLon(double lon)
  {
    return lon >= -180 && lon <= 180;
  }

  /** Haversine compute distance */
  double haversine(LatLon end)
  {
    double dLat = Math.degreesToRadians(end.lat - this.lat);
    double dLon = Math.degreesToRadians(end.lon - this.lon);
    double lat1 = Math.degreesToRadians(this.lat);
    double lat2 = Math.degreesToRadians(end.lat);

    double a = Math.sin(dLat/2) * Math.sin(dLat/2) +
               Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2);

    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));

    return RADII_KM * c;
  }

  /** Simple distance. From https://stackoverflow.com/questions/41515987/query-list-for-items-based-on-function-result */
  double getSimpleDistance(LatLon end)
  {
    double dLat = this.lat - end.lat;
    double dLon = this.lon - end.lon;
    dLon = dLon / 2;  // Lat Lon use different degrees
    return dLon * dLon  + dLat * dLat;
  }


  /**
   * Returns a nice string representing the coordinate.
   * @return {string} In the form (50, 73).
   * @override
   */
  @override
  String toString()
  {
    return "(" + this.lat.toString() + ", " + this.lon.toString() + ")";
  }

  @override
  int get hashCode
  {
    // From Effective Java.
    int result = 17;
    // Hash code for our fields. Note that field is read.
    result = 31 * result + lat.hashCode;
    result = 31 * result + lon.hashCode;
    return result;
  }

  /**
   * Compares coordinates for equality.
   */
  @override
  bool operator ==(Object other)
  {
    if (other is LatLon) {
      return this.lat == other.lat && this.lon == other.lon;
    }
    else {
      return false;
    }
  }

  /** Marshal method must operate by mutating empty object passed. */
  @override
  void marshal(MarshalledObject marshalled)
  {
    marshalled.setPropertyFromDouble("lat", lat);
    marshalled.setPropertyFromDouble("lon", lon);
  }

  /** Encoded object parameter is encoded depending on format. */
  static LatLon unmarshal(MarshalledObject marshalled)
  {
    double x = marshalled.getRequired("lat").asDouble();
    double y = marshalled.getRequired("lon").asDouble();
    return new LatLon(x, y);
  }
}


