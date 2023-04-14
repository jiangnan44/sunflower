

abstract class BaseDbDao {
  bool isTableExits = false;

  String innerTableName();

  String createColumns();


  String createTableSql() {
    return '''
    CREATE TABLE ${innerTableName()}( 
    ${createColumns()} )
    ''';
  }

}


