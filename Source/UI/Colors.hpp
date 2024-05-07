#pragma once

#include <QtCore>
#include <QImage>
#include <QObject>

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
            Light,
            Dark
        };
        Q_ENUM(Theme)

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