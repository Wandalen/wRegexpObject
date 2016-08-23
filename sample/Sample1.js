
if( typeof module !== 'undefined' )
require( 'wRegexpObject' );

var _ = wTools;

var regexpObject = _.RegexpObject( 'xxx','includeAny' );

console.log( 'regexpObject :\n' + _.toStr( regexpObject ) );
console.log( 'regexpObject.test( "xxx" ) :',regexpObject.test( 'xxx' ) );
