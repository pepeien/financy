#pragma once

#include <QtCore>
#include <QImage>

namespace Financy
{
    enum class ETheme
    {
        LIGHT,
        DARK
    };

    class ColorScheme : public QObject
    {
        Q_OBJECT

        Q_PROPERTY(
            QColor background
            MEMBER m_background
            NOTIFY colorsChanged
        )
        Q_PROPERTY(
            QColor foreground
            MEMBER m_foreground
            NOTIFY colorsChanged
        )
        Q_PROPERTY(
            QColor light
            MEMBER m_light
            NOTIFY colorsChanged
        )
        Q_PROPERTY(
            QColor dark
            MEMBER m_dark
            NOTIFY colorsChanged
        )

    signals:
        void colorsChanged();

    public:
        ColorScheme();

    public:
        void setBackgroundColor(const QColor& inColor);
        void setForegroundColor(const QColor& inColor);
        void setLightColor(const QColor& inColor);
        void setDarkColor(const QColor& inColor);

    private:
        QColor m_background;        
        QColor m_foreground;
        QColor m_light;
        QColor m_dark;
    };
}