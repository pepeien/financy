#pragma once

#include <QtCore>
#include <QObject>
#include <QImage>

namespace Financy
{
    class Colors : public QObject
    {
        Q_OBJECT

        // Properties
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
        Colors(QObject* parent = nullptr);
        ~Colors() = default;

        Colors& operator=(const Colors&) = default;

    // Types
    public:
        enum class Theme
        {
            Light = 0,
            Dark  = 1
        };
        Q_ENUM(Theme)

    public:
        void setBackgroundColor(const QColor& inColor);
        QColor getBackgroundColor();

        void setForegroundColor(const QColor& inColor);
        QColor getForegroundColor();

        void setLightColor(const QColor& inColor);
        QColor getLightColor();

        void setDarkColor(const QColor& inColor);
        QColor getDarkColor();

    private:
        QColor m_background;        
        QColor m_foreground;
        QColor m_light;
        QColor m_dark;
    };
}