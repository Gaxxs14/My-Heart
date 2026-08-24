package com.myheart.my_heart

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class LoveCounterWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.love_counter_widget).apply {
                val names = widgetData.getString("couple_names", "Gabriel & Mi Amor ♥")
                val days = widgetData.getString("days_count", "420")
                val label = widgetData.getString("days_label", "DÍAS JUNTOS")

                setTextViewText(R.id.widget_couple_names, names)
                setTextViewText(R.id.widget_days_count, days)
                setTextViewText(R.id.widget_days_label, label)

                // Open App on widget click
                val intent = Intent(context, MainActivity::class.java)
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
