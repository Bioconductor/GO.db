datacache <- new.env(hash=TRUE, parent=emptyenv())

GO <- function() showQCData("GO", datacache)
GO_dbconn <- function() dbFileConnect(GO_dbfile())
GO_dbfile <- function() dbfile(datacache)
GO_dbschema <- function(file="", show.indices=FALSE) dbschema(datacache, file=file, show.indices=show.indices)
GO_dbInfo <- function() dbInfo(datacache)

.onLoad <- function(libname, pkgname)
{
    ## Connect to the SQLite DB
    delayedAssign("dbfile", {
        cache(AnnotationHub()["AH67900"])
    }, assign.env = datacache)

    ## Create the OrgDb object
    sPkgname <- sub(".db$","",pkgname)
    dbNewname <- AnnotationDbi:::dbObjectName(pkgname,"GODb")
    ns <- asNamespace(pkgname)
    delayedAssign(dbNewname, {
        loadDb(GO_dbfile())
    }, assign.env = ns)
    namespaceExport(ns, dbNewname)

    ## Create the AnnObj instances
    delayedAssign("ann_objs", {
        ann_objs <- createAnnObjs.SchemaChoice("GO_DB", "GO", "GO", GO_dbconn(), datacache)
        ann_objs
    }, assign.env = datacache)
    NamespaceAndExport(ann_objs, pkgname)
    packageStartupMessage(AnnotationDbi:::annoStartupMessages("GO.db"))
}

.onUnload <- function(libpath)
{
    dbFileDisconnect(GO_dbconn())
}

