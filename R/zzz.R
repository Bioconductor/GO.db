datacache <- new.env(hash=TRUE, parent=emptyenv())

GO <- function() showQCData("GO", datacache)
GO_dbconn <- function() dbconn(datacache)
GO_dbfile <- function() dbfile(datacache)
GO_dbschema <- function(file="", show.indices=FALSE) dbschema(datacache, file=file, show.indices=show.indices)
GO_dbInfo <- function() dbInfo(datacache)

.onLoad <- function(libname, pkgname)
{
    ## Connect to the SQLite DB
    assign("dbfile", dbfile, envir=datacache)
    delayedAssign("dbfile", {
        cache(AnnotationHub()["AH67900"])
    }, assign.env = datacache)
    delayedAssign("dbconn", {
        dbFileConnect(dbfile)
    }, assign.env = datacache)

    ## Create the OrgDb object
    sPkgname <- sub(".db$","",pkgname)
    delayedAssign("txdb", {
        loadDb(dbfile)
    }, assign.env = datacache)
    dbNewname <- AnnotationDbi:::dbObjectName(pkgname,"GODb")
    ns <- asNamespace(pkgname)
    delayedAssign(dbNewname, {
        namespaceExport(ns, dbNewname)
        txdb
    }, assign.env = ns)

    ## Create the AnnObj instances
    delayedAssign("ann_objs", {
        ann_objs <- createAnnObjs.SchemaChoice("GO_DB", "GO", "GO", dbconn, datacache)
        mergeToNamespaceAndExport(ann_objs, pkgname)
        ann_objs
    }, assign.env = datacache)
    packageStartupMessage(AnnotationDbi:::annoStartupMessages("GO.db"))
}

.onUnload <- function(libpath)
{
    dbFileDisconnect(GO_dbconn())
}

