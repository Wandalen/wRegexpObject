( function _RegexpObject_s_() {

'use strict';

/**
  @module Tools/mid/RegexpObject - Class which encapsulates a trivial logical combination( expression ) and regular expressions which may be applied to a string to tell does that string satisfies regular expressions as well as the logic. RegexpObject provides functionality to compose, combine several instances of the class, extend it, apply to a string and other. Use it to treat multiple conditions as a single object. Refactoring required.
*/

/**
 * @file RegexpObject.s.
 */

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }

  var _ = _global_.wTools;

  _.include( 'wCopyable' );

}

//

/**
 * The complete RegexpObject object.
 * @typedef {Object} wRegexpObject
 * @property {RegExp[]} includeAny - Array of RegExps, to check matching any of them;
 * @property {RegExp[]} includeAll - Array of RegExps, to check matching all of them;
 * @property {RegExp[]} excludeAny - Array of RegExps, to check mismatch any of them;
 * @property {RegExp[]} excludeAll - Array of RegExps, to check mismatch all of them;
 * @memberof wRegexpObject
 */

var _ = _global_.wTools;
var Parent = null;
var Self = function wRegexpObject( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'RegexpObject';

//

  /**
   * Make RegexpObject from different type sources.
      If passed RegexpObject or map with properties similar to RegexpObject but with string in values, then the second
   parameter is not required;
      All strings in sources will be turned into RegExps.
      If passed single RegExp/String or array of RegExps/Strings, then method will return RegexpObject with
   `defaultMode` as key, and array of RegExps created from first parameter as value.
      If passed array of RegexpObject, mixed with ordinary RegExps/Strings, the result object will be created by merging
   with shrinking (see [shrink]{@link wTools#shrink}) RegexpObjects and RegExps that associates
   with `defaultMode` key.
   *
   * @example
     var src = [
         /hello/,
         'world',
         {
            includeAny : [ 'yellow', 'blue', 'red' ],
            includeAll : [ /red/, /green/, /brown/ ],
            excludeAny : [ /yellow/, /white/, /grey/ ],
            excludeAll : [ /red/, /green/, /blue/ ]
         }
     ];
     _.wRegexpObject( src, 'excludeAll' );

     // {
     //    includeAny: [ /yellow/, /blue/, /red/ ],
     //    includeAll: [ /red/, /green/, /brown/ ],
     //    excludeAny: [ /yellow/, /white/, /grey/ ],
     //    excludeAll: [ /hello/, /world/ ]
     // }
   * @param {RegexpObject|String|RegExp|RegexpObject[]|String[]|RegExp[]} src Source for making RegexpObject
   * @param {String} [defaultMode] key for result RegexpObject map. Can be one of next strings: 'includeAny',
   'includeAll','excludeAny' or 'excludeAll'.
   * @returns {RegexpObject} Result RegexpObject
   * @throws {Error} Missing arguments if call without argument
   * @throws {Error} Missing arguments if passed array without `defaultMode`
   * @throws {Error} Unknown mode `defaultMode`
   * @throws {Error} Unknown src if first argument is not array, map, string or regexp.
   * @throws {Error} Unexpected if type of array element is not string regexp or RegexpObject.
   * @throws {Error} Unknown regexp filters if passed map has unexpected properties (see RegexpObject).
   * @method init
   * @memberof wRegexpObject
   */

function init( src, defaultMode )
{
  var self = this;

  _.instanceInit( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  /**/

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.objectIs( src ) || _.arrayIs( src ) || _.regexpIs( src ) || _.strIs( src ) || src === null, () => 'Unknown type of arguments ' + _.strTypeOf( src ) );

  /**/

  if( _.regexpIs( src ) )
  src = [ src ];

  if( _.strIs( src ) )
  src = [ new RegExp( _.regexpEscape( src ) ) ];

  if( src === null )
  src = [];

  /**/

  if( _.arrayIs( src ) )
  {

    src = _.arrayFlatten( [],src );

    var ar = [];
    for( var s = 0 ; s < src.length ; s += 1 )
    {
      if( _.regexpIs( src[ s ] ) || _.strIs( src[ s ] ) )
      ar.push( _.regexpFrom( src[ s ] ) );
      else if( _.objectIs( src[ s ] ) )
      //_.RegexpObject.shrink( self,Self( src[ s ] ) );
      _.RegexpObject.broaden( self,Self( src[ s ] ) );
      else throw _.err( 'unexpected' );
    }

    if( ar.length )
    {

      _.assert( arguments.length === 2,'expects second argument as default mode, for example "includeAny"' );
      _.assert( !!self.Names[ defaultMode ], 'unknown mode :',defaultMode );

      if( self[ defaultMode ] && self[ defaultMode ].length )
      {
        var r = {};
        r[ defaultMode ] = ar;
        //_.RegexpObject.shrink( self,r );
        _.RegexpObject.broaden( self,r );
      }
      else
      {
        self[ defaultMode ] = ar;
      }
    }

  }
  else if( _.objectIs( src ) )
  {

    //debugger;
    //_.mapIs( src );

    _.eachOwn( src,function onEach( e,k )
    {
      if( e === null )
      {
        debugger;
        throw _.err( 'not tested' );
        delete self[ k ];
        return;
      }
      self[ k ] = _.regexpArrayMake( e );
    });

  }
  else _.assert( 0,'wRegexpObject :','unknown src',src );

  _.assertMapOwnOnly( self, self.Names, 'Unknown regexp fields' );

  // logger.log( 'RegExpObject\n' + self.toStr() );

  if( Config.debug )
  self.validate();

  return self;
}

//

function validate()
{
  var self = this;

  _.assert( arguments.length === 0 );

  for( var f in Composes )
  {
    _.assert( _.arrayIs( self[ f ] ) );
    for( var i = 0 ; i < self[ f ].length ; i++ )
    {
      _.assert( _.regexpIs( self[ f ][ i ] ),'Regexp object expects regexps, but got',_.strTypeOf( self[ f ][ i ] ) );
    }
  }

}

//

/**
 * Test the `ins` string by condition specified in `src`. If all condition are met, return true
 * _test( options, str ); // true
 * @param {Object} src Object with options for test
 * @param {Regexp[]} [src.excludeAll] Array with regexps for testing. If all of the regexps match at `ins` method
 * return the "excludeAll" string, otherwise checks next property in the `src` object
 * @param {Regexp[]} [src.excludeAny] Array with regexps for testing. If any of them match `ins` string` method return
 * it source string, otherwise checks next property in the `src` object
 * @param {Regexp[]} [src.includeAll] Array with regexps for testing. If all of them match `ins` string method check
 * next property in `src` object, otherwise return source of regexp that don't match.
 * @param {Regexp[]} [src.includeAny] Array with regexps for testing. If no one regexp don't match method return
 * "inlcude none from includeAny" string. Else method return true;
 * @param {String} ins String for testing
 * @returns {String|boolean} If all reason match, return true, otherwise return string with fail reason
 * @throws {Error} Throw an 'expects string' error if `ins` is not string
 * @throws {Error} Throw an 'expects object' error if `src` is not object
 * @method _test
 * @memberof wRegexpObject
*/

//function _test( src,ins )
function _test( ins )
{
  var src = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( !_.strIs( ins ) )
  throw _.err( 'test :','expects string as second argument',ins );

  if( src.excludeAll )
  {
    var r = _.regexpArrayAll( src.excludeAll,ins,false );
    if( r === true )
    return 'excludeAll';
  }

  if( src.excludeAny )
  {
    var r = _.regexpArrayAny( src.excludeAny,ins,false );
    if( r !== false )
    return src.excludeAny[ r ].source;
  }

  if( src.includeAll )
  {
    var r = _.regexpArrayAll( src.includeAll,ins,true );
    if( r !== true )
    return src.includeAll[ r ].source;
  }

  if( src.includeAny )
  {
    var r = _.regexpArrayAny( src.includeAny,ins,true );
    if( r === false )
    return 'include none from includeAny';
  }

  return true;
}

//

  /**
   * Function for testing `ins` string for different regexps combination. If all condition passed in `src` object are
   * met method return true
   *
   * @example
   * var str = "The RGB color model is an additive color model in which red, green, and blue light are added together in various ways to reproduce a broad array of colors";
   *     regArr1 = [/red/, /green/, /blue/],
   *     regArr2 = [/yellow/, /blue/, /red/],
   *     regArr3 = [/yellow/, /white/, /greey/],
   *     options = {
   *        includeAny : regArr2,
   *        includeAll : regArr1,
   *        excludeAny : regArr3,
   *        excludeAll : regArr2
   *     };
   *
   * wTools.test( options, str ); // true
   * @param {Object} src Map object in wich keys are strings each of them mean different condition for test, and values
   * are the arrays of regexps;
   * @param {Regexp[]} [src.excludeAll] Array with regexps for testing. If all of the regexps match at `ins` method
   * return false
   * @param {Regexp[]} [src.excludeAny] Array with regexps for testing. If any of them match `ins` string` method return
   * false
   * @param {Regexp[]} [src.includeAll] Array with regexps for testing. If any of them don't match `ins` string method
   * return false
   * @param {Regexp[]} [src.includeAny] Array with regexps for testing. If no one of regexps don't match `ins` string
   * method return false
   * @param ins String for testing
   * @returns {boolean} If all test passed return true;
   * @throws {Error} Throw an 'expects string' error if `ins` is not string
   * @throws {Error} Throw an 'expects object' error if `src` is not object
   * @method test
   * @memberof wRegexpObject
     */

//function test( src,ins )
function test( ins )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  var result = self._test( ins );

  if( _.strIs( result ) )
  return false;

  if( result === true )
  return true;

  throw _.err( 'unexpected' );
}

//

  /**
   * Function for testing `ins` string for different regexps combination. If all condition passed in `src` object are
   * met method return true
   *
   * @example
   * var str = "The RGB color model is an additive color model in which red, green, and blue light are added together in various ways to reproduce a broad array of colors";
   *     regArr1 = [/red/, /green/, /blue/],
   *     regArr2 = [/yellow/, /blue/, /red/],
   *     regArr3 = [/yellow/, /white/, /greey/],
   *     options = {
   *        includeAny : regArr2,
   *        includeAll : regArr1,
   *        excludeAny : regArr3,
   *        excludeAll : regArr2
   *     };
   *
   * wTools.test( options, str ); // true
   * @param {Object} src Map object in wich keys are strings each of them mean different condition for test, and values
   * are the arrays of regexps;
   * @param {Regexp[]} [src.excludeAll] Array with regexps for testing. If all of the regexps match at `ins` method
   * return false
   * @param {Regexp[]} [src.excludeAny] Array with regexps for testing. If any of them match `ins` string` method return
   * false
   * @param {Regexp[]} [src.includeAll] Array with regexps for testing. If any of them don't match `ins` string method
   * return false
   * @param {Regexp[]} [src.includeAny] Array with regexps for testing. If no one of regexps don't match `ins` string
   * method return false
   * @param ins String for testing
   * @returns {boolean} If all test passed return true;
   * @throws {Error} Throw an 'expects string' error if `ins` is not string
   * @throws {Error} Throw an 'expects object' error if `src` is not object
   * @method test
   * @memberof wRegexpObject
   */

function test_static( self,ins )
{

  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  //if( _.strIs( self ) || _.regexpIs( self ) )
  self = Self( self,'includeAll' );

  return self.test( ins );
}

//

function Shrink( dst )
{

  // if( dst === null )
  // dst = new Self();
  // else
  if( !( dst instanceof Self ) && dst !== null )
  dst = _.RegexpObject( dst, 'includeAny' )

  for( var a = 1 ; a < arguments.length ; a++ )
  {
    let src = arguments[ a ];
    if( dst === null )
    {
      if( src === null || src === undefined )
      continue;
      else if( src instanceof Self )
      dst = src.clone();
      else
      dst = new Self( src );
    }
    else
    {
      if( src !== null && src !== undefined )
      dst.shrink( src );
    }
  }

  if( dst === null )
  dst = new Self( null, 'includeAny' );

  return dst;

/*
  if( self.maskAll )
  self.maskAll = _.RegexpObject( self.maskAll,'includeAny' );

  if( self.maskAll && src.maskAll !== undefined )
  {
    self.maskAll.shrink( src.maskAll );
  }
  else if( src.maskAll )
  {
    if( src.maskAll instanceof _.RegexpObject )
    self.maskAll = src.maskAll.clone();
    else
    self.maskAll = _.RegexpObject( src.maskAll );
  }
*/
}

//

function shrink()
{
  var self = this;

  _regexpObjectExtend
  ({
    dst : this,
    srcs : arguments,
    shrinking : 1,
  });

  return self;
}

//

function broaden()
{
  var self = this;

  _regexpObjectExtend
  ({
    dst : this,
    srcs : arguments,
    shrinking : 0,
  });

  debugger;
  throw _.err( 'not tested' );

  return self;
}

//

function isEmpty()
{
  var self = this;

  if( self.includeAny.length > 0 )
  return false;
  if( self.includeAll.length > 0 )
  return false;
  if( self.excludeAny.length > 0 )
  return false;
  if( self.excludeAll.length > 0 )
  return false;

  return true;
}

//

  /**
   * Extends `result` of RegexpObjects by merging other RegexpObjects.
   * The properties such as includeAll, excludeAny are complemented from appropriate properties in source  objects
     by merging all of them;
   * Properties includeAny and excludeAll are always replaced by appropriate properties from sources without merging,
   *
   * @example
   * var dest = {
   *     includeAny : [/yellow/, /blue/],
   *     includeAll : [/red/],
   *     excludeAny : [/yellow/],
   *     excludeAll : [/red/]
   * },
   *
   * src1 = {
   *     includeAll : [/green/],
   *     excludeAny : [/white/],
   *     excludeAll : [/green/, /blue/]
   * },
   * src2 = {
   *     includeAny : [/red/],
   *     includeAll : [/brown/],
   *     excludeAny : [/greey/],
   * }
   *
   * wTools.shrink(dest, src1, src2);
   *
   * //{
   * //    includeAny : [/red/],
   * //    includeAll : [/red/, /green/, /brown/],
   * //    excludeAny : [/yellow/, /white/, /greey/],
   * //    excludeAll : [/green/, /blue/]
   * //};
   * @param {RegexpObject} result RegexpObject to merge in.
   * @param {...RegexpObject} [src] RegexpObjects to merge from.
   * @returns {RegexpObject} Reference to `result` parameter;
   * @throws {Error} If missed arguments
   * @throws {Error} If arguments are not RegexpObject
   * @method shrink
   * @memberof wRegexpObject
   */

function shrink_class( dst )
{

  var result = _regexpObjectExtend
  ({
    dst : dst,
    srcs : _.longSlice( arguments,1 ),
    shrinking : 1,
  });

  return result;
}

//

/**
 * Extends `result` of RegexpObjects by merging other RegexpObjects.
 * Appropriate properties such as includeAny, includeAll, excludeAny and excludeAll are complemented from appropriate
 * properties in source objects by merging;
 *
 * @example
 * var dest = {
 *     includeAny : [/yellow/, /blue/],
 *     includeAll : [/red/],
 *     excludeAny : [/yellow/],
 *     excludeAll : [/red/]
 * },
 *
 * src1 = {
 *     includeAll : [/green/],
 *     excludeAny : [/white/],
 *     excludeAll : [/green/, /blue/]
 * },
 * src2 = {
 *     includeAny : [/red/],
 *     includeAll : [/brown/],
 *     excludeAny : [/greey/],
 * }
 *
 * wTools.broaden(dest, src1, src2);
 *
 * //{
 * //    includeAny : [/yellow/, /blue/, /red/],
 * //    includeAll : [/red/, /green/, /brown/],
 * //    excludeAny : [/yellow/, /white/, /greey/],
 * //    excludeAll : [/red/, /green/, /blue/]
 * //};
 * @param {RegexpObject} result RegexpObject to merge in.
 * @param {...RegexpObject} [src] RegexpObjects to merge from.
 * @returns {RegexpObject} Reference to `result` parameter;
 * @throws {Error} If missed arguments
 * @throws {Error} If arguments are not RegexpObject
 * @method broaden
 * @memberof wRegexpObject
 */

function broaden_class( dst )
{

  var result = _regexpObjectExtend
  ({
    dst : dst,
    srcs : _.longSlice( arguments,1 ),
    shrinking : 0,
  });

  //debugger;
  // throw _.err( 'not tested' );

  return result;
}

//

/**
 * Merge several RegexpObjects extending one by others.
    Order of extending make difference because joining of some parameters without lose is not possible.
    o.shrinking gives a hint in what direction the lost should be made.

 * @param {object} o - options of merging.
 * @param {RegexpObject} options.dst
    RegexpObject to merge in.
 * @param {RegexpObject} options.srcs -
    RegexpObjects to merge from.
 * @param {Boolean} options.shrinking -
    Shrinking or broadening mode.
    Joining of some parameters without lose is not possible.
    This parameter gives a hint in what direction the lost should be made.
 * @returns {RegexpObject}
    merged RegexpObject.
 * @throws {Error} If in options missed any of 'dst', 'srcs' or 'shrinking' properties
 * @throws {Error} If options.dst is not object
 * @throws {Error} If options.srcs is not longIs object
 * @throws {Error} If options.srcs element is not RegexpObject object
 * @method _regexpObjectExtend
 * @memberof wRegexpObject
 */

function _regexpObjectExtend( o )
{

  if( o.dst === null )
  o.dst = new Self( [] );

  _.routineOptions( _regexpObjectExtend,o );
  _.assert( _.objectIs( o.dst ) );
  _.assert( _.longIs( o.srcs ) );

  o.srcs = _.arrayFlatten( [],o.srcs );

  var result = o.dst;
  for( var n in Names )
  if( !result[ n ] )
  result[ n ] = [];
  result = Self( result );

  for( var s = 0 ; s < o.srcs.length ; s++ )
  {
    var src = o.srcs[ s ];

    if( src === null )
    {
      continue;
    }
    else if( !_.objectIs( src ) )
    {
      debugger;
      throw _.err( 'regexpObjectExtend :','argument must be regexp object',src );
    }

    _.assertMapOwnOnly( src,Names );

    var toExtend = o.shrinking ? RegexpModeNamesToExtendMap : Names;

    for( var n in toExtend )
    if( src[ n ] )
    if( ( _.arrayIs( src[ n ] ) && src[ n ].length ) || !_.arrayIs( src[ n ] ) )
    {
      result[ n ] = _.arrayFlatten( result[ n ], [ src[ n ] ] );
    }

    if( o.shrinking )
    for( var n in RegexpModeNamesToReplaceMap )
    if( src[ n ] )
    if( ( _.arrayIs( src[ n ] ) && src[ n ].length ) || !_.arrayIs( src[ n ] ) )
    {
      if( _.regexpIs( src[ n ] ) )
      result[ n ] = [ src[ n ] ];
      else
      result[ n ] = src[ n ];
    }

  }

  /* normalize */

  for( var r in result )
  for( var i = 0; i < result[ r ].length ; i++ )
  {
    var element = result[ r ][ i ];
    if( _.strIs( element ) )
    result[ r ][ i ] = new RegExp( _.regexpEscape( element ) );
  }

  /* */

  _.assert( result instanceof Self );
  if( Config.debug )
  result.validate();

  return result;
}

_regexpObjectExtend.defaults =
{
  dst : null,
  srcs : null,
  shrinking : true,
}

//

/**
 * Create RegexpObject, that represents the subtraction for match`s/mismatched with the input RegexpObject object
 e.g. if { includeAll: [ /red/, /green/, /blue/ ] } represents subset of all strings that contains each 'red', 'green'
 and 'blue' words, then result of but() - { excludeAll: [ /red/, /green/, /blue/ ]} will represent the
 subset of all strings that does not contains at least one of those worlds.
 *
 * @example
   var options = {
         includeAny : [/yellow/, /blue/, /red/],
         includeAll : [/red/, /green/, /blue/],
         excludeAny : [/yellow/, /white/, /grey/],
         excludeAll : [/black/, /brown/, /pink/]
     };

   wTools.but(options);

    // {
    //   "includeAny":[/yellow/, /white/, /grey/],
    //   "excludeAny":[/yellow/, /blue/, /red/],
    //   "excludeAll":[/red/, /green/, /blue/],
    //   "includeAll":[/black/, /brown/, /pink/]
    // }
 * @param {...RegexpObject|...String|...RegExp} [src] Input RegexpObject map/maps. If passed primitive values, they will
 be interpreted as value for `includeAny` property of RegexpObject. If objects more than one, their includeAny and
 excludeAny properties will be merged. Notice: if objects more than one and every has includeAll/excludeAll arrays
 with more than one elements, method will throw error.
 * @returns {RegexpObject} Result RegexpObject map.
 * @throws {Error} If objects more than one and every has includeAll/excludeAll arrays with more than one elements
 * throws 'cant combineMethodUniform such regexp objects with "but" combiner'
 * @method but
 * @memberof wRegexpObject
 */

function but()
{
  var result = Self( [],Self.Names.includeAny );

  for( var a = 0, al = arguments.length ; a < al ; a++ )
  {
    var argument = arguments[ a ];
    var src = Self( argument,Self.Names.includeAny );

    if( src.includeAny ) result.excludeAny = _.arrayAppendArray( result.excludeAny || [], src.includeAny );
    if( src.excludeAny ) result.includeAny = _.arrayAppendArray( result.includeAny || [], src.excludeAny );

    if( src.includeAll && src.includeAll.length )
    {
      if( src.includeAll.length === 1 )
      {
        result.excludeAny = _.arrayAppendArray( result.excludeAny || [], src.includeAll );
      }
      else if( !result.excludeAll || result.excludeAll.length === 0 )
      {
        result.excludeAll = _.arrayAppendArray( result.excludeAll || [], src.includeAll );
      }
      else throw _.err( 'but :','cant combineMethodUniform such regexp objects with "but" combiner' );
    }

    if( src.excludeAll && src.excludeAll.length )
    {
      if( src.excludeAll.length === 1 )
      {
        result.includeAny = _.arrayAppendArray( result.includeAny || [], src.excludeAll );
      }
      else if( !result.includeAll || result.includeAll.length === 0 )
      {
        result.includeAll = _.arrayAppendArray( result.includeAll || [], src.excludeAll );
      }
      else throw _.err( 'but :','cant combineMethodUniform such regexp objects with "but" combiner' );
    }

    /*
    var result = _.regexpMakeObject
    ({

      includeAny : src.excludeAny,
      includeAll : src.excludeAll,
      excludeAny : src.includeAny,
      excludeAll : src.includeAll,

    });
    */

  }

  return result;
}

//

/**
 * Creates array of RegexpObjects, that will be associated with some ordered set of subsets of strings.
 Accepts array of strings. They will be used as base for RegexpObjects. The empty string in array will be
 converted into RegexpObject that associates with subset what is the subtraction of all possible subsets of strings
 and union of subsets which match other words in array.
 If several arrays are passed in the method, the result will be cartesian product of appropriates arrays described
 above.
 * @example
 *
 var arr1 = ['red', 'blue'],
 arr2 = ['', 'green'];

 wTools.order(arr1, arr2);
 // [
 //     {
 //         includeAny:[],
 //         includeAll:[/red/],
 //         excludeAny:[/green/],
 //         excludeAll:[]},
 //
 //     {
 //         includeAny:[],
 //         includeAll:[/red/,/green/],
 //         excludeAny:[],
 //         excludeAll:[]},
 //
 //     {
 //         includeAny:[],
 //         includeAll:[/blue/],
 //         excludeAny:[/green/],
 //         excludeAll:[]},
 //
 //     {
 //         includeAny:[],
 //         includeAll:[/blue/, /green/],
 //         excludeAny:[],
 //         excludeAll:[]
 //     }
 // ]
 * @param {...String[]} ordering аrray/аrrays of strings
 * @returns {RegexpObject[]} аrray of RegexpObject that represent resulting ordering
 * @throws {Error} Unexpected type, if passed arguments is not arrays.
 * @method order
 * @memberof wRegexpObject
 */

function order( ordering )
{
  var res = [];

  if( arguments.length === 1 && arguments[ 0 ].length === 0 )
  return res;

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var argument = arguments[ a ];
    if( _.arrayIs( argument[ 0 ] ) )
    for( var i = 0 ; i < argument.length ; i++ )
    res.push( _regexpObjectOrderingExclusion( argument[ i ] ) );
    else if( _.strIs( argument[ 0 ] ) )
    res.push( _regexpObjectOrderingExclusion( argument ) );
    else throw _.err( 'unexpected' );
  }

  if( res.length === 1 )
  return res[ 0 ];

  var result = [];
  _.eachSample
  ({
    leftToRight : 0,
    sets : res,
    onEach : function( sample,index )
    {
      var mask = _.RegexpObject.shrink( {},sample[ 0 ] );
      for( var s = 1 ; s < sample.length ; s++ )
      _.RegexpObject.shrink( mask,sample[ s ] );
      result.push( mask );
    }
  });

  return result;
}

//

/**
 * Wrap strings passed in `ordering` array into RegexpObjects.
    Any non empty string in input array turns into RegExp which is wraped into array and assign to includeAll,
 property of appropriate object. An empty string in array are replaced by merged subtractions for all created
 RegexpObjects objects.

 * @param {String[]} ordering - array of strings.
 * @returns {RegexpObject[]} Returns array of RegexpObject
 * @private
 * @throws {Error} If no arguments, or arguments more than 1.
 * @method _regexpObjectOrderingExclusion
 * @memberof wRegexpObject
 */

function _regexpObjectOrderingExclusion( ordering )
{

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !ordering || _.arrayIs( ordering ) );

  if( !ordering )
  return [];

  if( !ordering.length )
  return ordering;

  var result = [];

  for( var o = 0 ; o < ordering.length ; o++ )
  {
    _.assert( _.strIs( ordering[ o ] ) );
    if( ordering[ o ] === '' )
    continue;
    result.push( Self( ordering[ o ],Names.includeAll ) );
  }

  var nomask = {};
  for( var r = 0 ; r < result.length ; r++ )
  {
    _.RegexpObject.shrink( nomask,Self.but( result[ r ] ) );
  }

  for( var o = 0 ; o < ordering.length ; o++ )
  {
    if( ordering[ o ] === '' )
    result.splice( o,0,nomask );
  }

/*
  var before = _.regexpMakeObject( before,regexpMakeObject.names.includeAll );
  var after = _.regexpMakeObject( after,regexpMakeObject.names.includeAll );

  return [
    before,
    Self.but( before,after ),
    after,
  ];
*/

  return result;
}

//

// function toStr( o )
// {
//   var self = this;
//   var o = o || {};
//
//   if( o.levels === undefined )
//   o.levels = 3;
//
//   var result = self.toStr_functor({ fields : [ self.Composes,self.Aggregates ] }).call( self,o );
//
//   return result;
// }

// --
// class var
// --

var Names = _.namesCoded
({
  includeAny : 'includeAny',
  includeAll : 'includeAll',
  excludeAny : 'excludeAny',
  excludeAll : 'excludeAll',
});

var RegexpModeNamesToExtendMap = _.namesCoded
({
  includeAll : 'includeAll',
  excludeAny : 'excludeAny',
});

var RegexpModeNamesToReplaceMap = _.namesCoded
({
  includeAny : 'includeAny',
  excludeAll : 'excludeAll',
});

// --
// relations
// --

var Composes =
{
  includeAny : _.define.own([]),
  includeAll : _.define.own([]),
  excludeAny : _.define.own([]),
  excludeAll : _.define.own([]),
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

var Statics =
{

  test : test_static,

  Shrink : Shrink,

  shrink : shrink_class,
  broaden : broaden_class,
  _regexpObjectExtend : _regexpObjectExtend,

  but : but,

  order : order,
  _regexpObjectOrderingExclusion : _regexpObjectOrderingExclusion,

  Names : Names,
  RegexpModeNamesToExtendMap : RegexpModeNamesToExtendMap,
  RegexpModeNamesToReplaceMap : RegexpModeNamesToReplaceMap,

}

// --
// declare
// --

var Extend =
{

  init : init,
  validate : validate,

  _test : _test,
  test : test,

  Shrink : Shrink,

  shrink : shrink,
  broaden : broaden,

  isEmpty : isEmpty,

  // relations

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

var Supplement =
{
  Statics : Statics,
}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
  supplement : Supplement,
});

_.Copyable.mixin( Self );

// --
// export
// --

_global_[ Self.name ] = _[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
