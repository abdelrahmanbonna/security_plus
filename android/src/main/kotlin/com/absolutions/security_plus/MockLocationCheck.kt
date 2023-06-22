//package com.absolutions.security_plus
//
//import android.content.Context
//import android.location.Location
//import android.location.LocationListener
//import android.location.LocationManager
//import android.os.Bundle
//import java.util.Timer
//import java.util.TimerTask
//
//
//class MockLocationCheck {
//    var timer1: Timer? = null
//    var lm: LocationManager? = null
//    var locationResult: LocationResult? = null
//    var gpsEnabled = false
//    var networkEnabled = false
//
//    fun getLocation(context: Context, result: LocationResult?): Boolean {
//        //I use LocationResult callback class to pass location value from MockLocationCheck to user code.
//        locationResult = result
//        if (lm == null) lm = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
//
//        //exceptions will be thrown if provider is not permitted.
//        try {
//            gpsEnabled = lm!!.isProviderEnabled(LocationManager.GPS_PROVIDER)
//        } catch (_: Exception) {
//        }
//        try {
//            networkEnabled = lm!!.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
//        } catch (_: Exception) {
//        }
//
//        //don't start listeners if no provider is enabled
//        if (!gpsEnabled && !networkEnabled) return false
//        if (gpsEnabled) lm!!.requestLocationUpdates(
//            LocationManager.GPS_PROVIDER, 0, 0f,
//            locationListenerGps!!
//        ) else if (networkEnabled) {
//             lm!!.requestLocationUpdates(
//                LocationManager.NETWORK_PROVIDER, 0, 0f,
//                locationListenerNetwork!!
//            )
//        }
//        timer1 = Timer()
//        timer1!!.schedule(GetLastLocation(), 20000)
//        return true
//    }
//
//    var locationListenerGps: LocationListener? = object : LocationListener {
//        override fun onLocationChanged(location: Location) {
//            timer1!!.cancel()
//            locationResult!!.gotLocation(location)
//            lm!!.removeUpdates(this)
//            lm!!.removeUpdates(locationListenerNetwork!!)
//            lm!!.removeUpdates(this)
//        }
//
//        override fun onProviderDisabled(provider: String) {}
//        override fun onProviderEnabled(provider: String) {}
//        @Deprecated("Deprecated in Java")
//        override fun onStatusChanged(provider: String, status: Int, extras: Bundle) {}
//    }
//    var locationListenerNetwork: LocationListener? = object : LocationListener {
//        override fun onLocationChanged(location: Location) {
//            timer1!!.cancel()
//            locationResult!!.gotLocation(location)
//            lm!!.removeUpdates(this)
//            lm!!.removeUpdates(locationListenerGps!!)
//            lm!!.removeUpdates(this)
//        }
//
//        override fun onProviderDisabled(provider: String) {}
//        override fun onProviderEnabled(provider: String) {}
//        @Deprecated("Deprecated in Java")
//        override fun onStatusChanged(provider: String, status: Int, extras: Bundle) {}
//    }
//
//    internal inner class GetLastLocation : TimerTask() {
//        override fun run() {
//            lm!!.removeUpdates(locationListenerGps!!)
//            lm!!.removeUpdates(locationListenerNetwork!!)
//            var netLoc: Location? = null
//            var gpsLoc: Location? = null
//            if (gpsEnabled) gpsLoc = lm!!.getLastKnownLocation(LocationManager.GPS_PROVIDER)
//            if (networkEnabled) netLoc =
//                lm!!.getLastKnownLocation(LocationManager.NETWORK_PROVIDER)
//
//            //if there are both values use the latest one
//            if (gpsLoc != null && netLoc != null) {
//                if (gpsLoc.time > netLoc.time) locationResult!!.gotLocation(gpsLoc) else locationResult!!.gotLocation(
//                    netLoc
//                )
//                return
//            }
//            if (gpsLoc != null) {
//                locationResult!!.gotLocation(gpsLoc)
//                return
//            }
//            if (netLoc != null) {
//                locationResult!!.gotLocation(netLoc)
//                return
//            }
//            locationResult!!.gotLocation(null)
//        }
//    }
//
//    abstract class LocationResult {
//        abstract fun gotLocation(location: Location?)
//    }
//}
