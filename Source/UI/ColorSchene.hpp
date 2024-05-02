#pragma once

#include <QtCore>

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
            QString background
            MEMBER m_background
            NOTIFY themeChanged
        )
        Q_PROPERTY(
            QString foreground
            MEMBER m_foreground
            NOTIFY themeChanged
        )
        Q_PROPERTY(
            QString light
            MEMBER m_light
            NOTIFY themeChanged
        )
        Q_PROPERTY(
            QString dark
            MEMBER m_dark
            NOTIFY themeChanged
        )

    signals:
        void themeChanged();

    public:
        ColorScheme();

    public:
        void setTheme(ETheme theme);

    private:
        void onThemeChange();

    private:
        ETheme m_theme;
        QString m_background;        
        QString m_foreground;
        QString m_light;
        QString m_dark;
    };
}