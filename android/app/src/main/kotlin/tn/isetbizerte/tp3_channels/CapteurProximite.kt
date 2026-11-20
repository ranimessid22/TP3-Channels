package tn.isetbizerte.tp3_channels

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.plugin.common.EventChannel

/**
 * Exercice 1 : canal "capteur/proximite" (EventChannel).
 * Envoie true quand un objet est proche du téléphone, false sinon.
 */
class CapteurProximite(context: Context) : EventChannel.StreamHandler, SensorEventListener {

    private val sensorManager = context.getSystemService(SensorManager::class.java)
    private val capteur: Sensor? = sensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY)
    private var sink: EventChannel.EventSink? = null

    // Flutter commence à écouter
    override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
        if (capteur == null) {
            events.error("PAS_DE_CAPTEUR", "Ce téléphone n'a pas de capteur de proximité", null)
            return
        }
        sink = events
        sensorManager.registerListener(this, capteur, SensorManager.SENSOR_DELAY_NORMAL)
    }

    // Flutter arrête d'écouter : on libère le capteur
    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(this)
        sink = null
    }

    // Un objet est proche si la distance mesurée est inférieure à la portée maximale du capteur
    override fun onSensorChanged(event: SensorEvent) {
        val portee = capteur?.maximumRange ?: return
        val proche = event.values[0] < portee
        sink?.success(proche)
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
}
