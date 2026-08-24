package com.myheart.my_heart

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PetWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.pet_widget).apply {
                val name = widgetData.getString("pet_name", "Corazoncito")
                val emoji = widgetData.getString("pet_emoji", "🐶")
                val level = widgetData.getString("pet_level", "Nivel 1 · Amor Puro 💕")

                setTextViewText(R.id.widget_pet_name, name)
                setTextViewText(R.id.widget_pet_emoji, emoji)
                setTextViewText(R.id.widget_pet_level, level)

                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    2,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_pet_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
