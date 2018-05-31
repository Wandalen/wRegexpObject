
if( typeof module !== 'undefined' )
require( 'wRegexpObject' );
var _ = wTools;

var regexpObject = _.RegexpObject( 'abc','includeAny' );

console.log( 'regexpObject :\n' + _.toStr( regexpObject ) );
console.log( 'regexpObject.test( "abc" ) :',regexpObject.test( 'abc' ) );
