#include "Application.hpp"

#include "FileSystem.hpp"

namespace Financy
{
    Application::Application()
    {}

    Application::Application(const std::string& inTitle)
        : Application(
            inTitle,
            Colors::Theme::Light
        )
    {}

    Application::Application(const std::string& inTitle, Colors::Theme inTheme)
        : m_title(inTitle),
        m_theme(inTheme)
    {}

    int Application::run(int argc, char *argv[])
    {
        QApplication app(argc, argv);

        QQuickView viewer;
        viewer.setFlags(Qt::WindowType::Window | Qt::WindowType::FramelessWindowHint);
        viewer.setResizeMode(QQuickView::SizeRootObjectToView);
        viewer.setMinimumWidth(1600);
        viewer.setMinimumHeight(900);
        viewer.setTitle(QString::fromStdString(m_title));
        viewer.setColor("transparent");

        QQmlContext* content = viewer.rootContext();

        // Internals
        std::unique_ptr<Internals> m_internals = std::make_unique<Internals>();
        content->setContextProperty(
            "internals",
            m_internals.release()
        );

        viewer.setSource(QUrl("qrc:/Pages/Root.qml"));

        QObject::connect(
            viewer.engine(),
            &QQmlEngine::quit,
            &viewer,
            &QWindow::close
        );

        viewer.show();

        return app.exec();
    }
}