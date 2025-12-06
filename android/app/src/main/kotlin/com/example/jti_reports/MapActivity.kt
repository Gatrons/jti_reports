package com.example.jti_reports

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.preference.PreferenceManager
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.mylocation.GpsMyLocationProvider
import org.osmdroid.views.overlay.mylocation.MyLocationNewOverlay

class MapActivity : AppCompatActivity() {

    private lateinit var map: MapView
    private lateinit var locationOverlay: MyLocationNewOverlay

    private val LOCATION_PERMISSION_REQUEST = 1001

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Load konfigurasi osmdroid (aman walau sebelumnya sudah dipanggil di MainActivity)
        val ctx = applicationContext
        Configuration.getInstance().load(
            ctx,
            PreferenceManager.getDefaultSharedPreferences(ctx)
        )
        Configuration.getInstance().userAgentValue = BuildConfig.APPLICATION_ID

        setContentView(R.layout.activity_map)

        map = findViewById(R.id.mapView)
        map.setTileSource(TileSourceFactory.MAPNIK)
        map.setMultiTouchControls(true)  // pinch zoom, dll.

        // Cek & minta izin lokasi
        requestLocationPermissionIfNeeded()
    }

    // === Runtime Permission Lokasi ===
    private fun requestLocationPermissionIfNeeded() {
        val fine = Manifest.permission.ACCESS_FINE_LOCATION
        val coarse = Manifest.permission.ACCESS_COARSE_LOCATION

        val fineGranted = ContextCompat.checkSelfPermission(this, fine) ==
                PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(this, coarse) ==
                PackageManager.PERMISSION_GRANTED

        if (!fineGranted || !coarseGranted) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(fine, coarse),
                LOCATION_PERMISSION_REQUEST
            )
        } else {
            initMyLocationOverlay()
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == LOCATION_PERMISSION_REQUEST) {
            if (grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            ) {
                initMyLocationOverlay()
            } else {
                Toast.makeText(this, "Izin lokasi ditolak", Toast.LENGTH_SHORT).show()
                // Map tetap bisa dipakai, tapi tanpa titik lokasi user
            }
        }
    }

    // === Overlay lokasi saat ini + follow location ===
    private fun initMyLocationOverlay() {
        // Provider lokasi (GPS + network)
        val provider = GpsMyLocationProvider(this)
        locationOverlay = MyLocationNewOverlay(provider, map)

        locationOverlay.enableMyLocation()      // ambil lokasi
        locationOverlay.enableFollowLocation()  // kamera mengikuti user

        map.overlays.add(locationOverlay)

        // Begitu lokasi pertama berhasil didapat, zoom ke situ
        locationOverlay.runOnFirstFix {
            runOnUiThread {
                val myLocation: GeoPoint? = locationOverlay.myLocation
                if (myLocation != null) {
                    val controller = map.controller
                    controller.setZoom(18.0)
                    controller.animateTo(myLocation)
                }
            }
        }
    }

    // Opsional: fungsi untuk ambil lat/lng sekarang (misalnya mau dikirim balik ke Flutter / laporan)
    private fun getCurrentLatLng(): Pair<Double, Double>? {
        val point: GeoPoint? = locationOverlay.myLocation
        return if (point != null) {
            Pair(point.latitude, point.longitude)
        } else {
            null
        }
    }

    // === Lifecycle wajib untuk osmdroid ===
    override fun onResume() {
        super.onResume()
        map.onResume()
    }

    override fun onPause() {
        super.onPause()
        map.onPause()
    }
}
