 CREATE VIRTUAL TABLE WordText USING fts4(ArabicWord,Definition);
  
  CREATE TABLE WordMetadata (RootWordId INTEGER, IsRoot INTEGER);

  CREATE VIEW Words AS SELECT WordMetadata.rowid AS rowid, RootWordId, IsRoot, ArabicWord, Definition
      FROM WordMetadata JOIN WordText ON WordMetadata.rowid = WordText.rowid;

  CREATE TRIGGER word_insert INSTEAD OF INSERT ON Words
  BEGIN
    INSERT INTO WordMetadata (RootWordId,IsRoot) VALUES (NEW.RootWordId,NEW.IsRoot);
    INSERT INTO WordText (rowid, ArabicWord,Definition) VALUES (last_insert_rowid(), NEW.ArabicWord, NEW.Definition);
  END;

  CREATE TRIGGER word_delete INSTEAD OF DELETE ON Words
  BEGIN
    DELETE FROM WordMetadata WHERE rowid = OLD.rowid;
    DELETE FROM WordText WHERE rowid = OLD.rowid;
  END;
