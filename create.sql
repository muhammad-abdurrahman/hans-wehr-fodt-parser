 CREATE VIRTUAL TABLE Word USING fts4(ArabicWord,Definition);
  
  CREATE TABLE WordMetadata (RootWordId INTEGER, IsRoot INTEGER);

  CREATE VIEW WordView AS SELECT WordMetadata.rowid AS rowid, RootWordId, IsRoot, ArabicWord, Definition
      FROM WordMetadata JOIN Word ON WordMetadata.rowid = Word.rowid;

  CREATE TRIGGER word_insert INSTEAD OF INSERT ON WordView
  BEGIN
    INSERT INTO WordMetadata (RootWordId,IsRoot) VALUES (NEW.RootWordId,NEW.IsRoot);
    INSERT INTO Word (rowid, ArabicWord,Definition) VALUES (last_insert_rowid(), NEW.ArabicWord, NEW.Definition);
  END;

  CREATE TRIGGER word_delete INSTEAD OF DELETE ON WordView
  BEGIN
    DELETE FROM WordMetadata WHERE rowid = OLD.rowid;
    DELETE FROM Word WHERE rowid = OLD.rowid;
  END;
