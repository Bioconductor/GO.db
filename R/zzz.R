datacache <- new.env(hash=TRUE, parent=emptyenv())

GO <- function() showQCData("GO", datacache)
GO_dbconn <- function() dbconn(datacache)
GO_dbfile <- function() dbfile(datacache)
GO_dbschema <- function(file="", show.indices=FALSE) dbschema(datacache, file=file, show.indices=show.indices)
GO_dbInfo <- function() dbInfo(datacache)

.onLoad <- function(libname, pkgname)
{
    ## Connect to the SQLite DB
    dbfile <- cache(AnnotationHub()["AH67900"])
    assign("dbfile", dbfile, envir=datacache)
    dbconn <- dbFileConnect(dbfile)
    assign("dbconn", dbconn, envir=datacache)

    ## Create the OrgDb object
    sPkgname <- sub(".db$","",pkgname)
    txdb <- loadDb(dbfile)
    dbNewname <- AnnotationDbi:::dbObjectName(pkgname,"GODb")
    ns <- asNamespace(pkgname)
    assign(dbNewname, txdb, envir=ns)
    namespaceExport(ns, dbNewname)

    ## Create the AnnObj instances
    ann_objs <- createAnnObjs.SchemaChoice("GO_DB", "GO", "GO", dbconn, datacache)
    mergeToNamespaceAndExport(ann_objs, pkgname)
    packageStartupMessage(AnnotationDbi:::annoStartupMessages("GO.db"))
}

.onUnload <- function(libpath)
{
    dbFileDisconnect(GO_dbconn())
}
