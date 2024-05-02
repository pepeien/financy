#include "Main.hpp"

#include <QtWidgets>
#include <QtQuick>
#include <QtCore>
#include <QtQml>

#include "UI/ColorSchene.hpp"
#include "UI/User.hpp"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    std::unique_ptr<Financy::ColorScheme> lightColorScheme = std::make_unique<Financy::ColorScheme>();
    QList<Financy::User*> users;

    QQuickView viewer;
    viewer.setTitle(QStringLiteral("Financy"));
    viewer.rootContext()->setContextProperty("colorScheme", lightColorScheme.get());
    viewer.rootContext()->setContextProperty("users", QVariant::fromValue(users));
    viewer.setSource(QUrl("qrc:/Pages/Login.qml"));
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);

    QObject::connect(
        viewer.engine(),
        &QQmlEngine::quit,
        &viewer,
        &QWindow::close
    );

    viewer.show();

    return app.exec();
}