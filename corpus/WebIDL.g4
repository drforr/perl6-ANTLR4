grammar WebIDL;


webIDL
	: definitions EOF
;


definitions
	: extendedAttributeList definition definitions
	| 
;

definition
	: callbackOrInterface
	| partial
	| dictionary
	| enum_
	| typedef
	| implementsStatement
;

callbackOrInterface
	: 'callback' callbackRestOrInterface
	| interface_
;

callbackRestOrInterface
	: callbackRest
	| interface_
;

interface_
	: 'interface' IDENTIFIER_WEBIDL inheritance '{' interfaceMembers '}' ';'
;

partial
	: 'partial' partialDefinition
;

partialDefinition
	: partialInterface
	| partialDictionary
;

partialInterface
	: 'interface' IDENTIFIER_WEBIDL '{' interfaceMembers '}' ';'
;

interfaceMembers
	: extendedAttributeList interfaceMember interfaceMembers
	| 
;

interfaceMember
	: const_
	| operation
	| serializer
	| stringifier
	| staticMember
	| iterable
	| readonlyMember
	| readWriteAttribute
	| readWriteMaplike
	| readWriteSetlike
;

dictionary
	: 'dictionary' IDENTIFIER_WEBIDL inheritance '{' dictionaryMembers '}' ';'
;

dictionaryMembers
	: extendedAttributeList dictionaryMember dictionaryMembers
	| 
;

dictionaryMember
	: required type IDENTIFIER_WEBIDL default_ ';'
;

required
	: 'required'
	| 
;

partialDictionary
	: 'dictionary' IDENTIFIER_WEBIDL '{' dictionaryMembers '}' ';'
;

default_
	: '=' defaultValue
	| 
;

defaultValue
	: constValue
	| STRING_WEBIDL
	| '[' ']'
;

inheritance
	: ':' IDENTIFIER_WEBIDL
	| 
;

enum_
	: 'enum' IDENTIFIER_WEBIDL '{' enumValueList '}' ';'
;

enumValueList
	: STRING_WEBIDL enumValueListComma
;

enumValueListComma
	: ',' enumValueListString
	| 
;

enumValueListString
	: STRING_WEBIDL enumValueListComma
	| 
;

callbackRest
	: IDENTIFIER_WEBIDL '=' returnType '(' argumentList ')' ';'
;

typedef
	: 'typedef' type IDENTIFIER_WEBIDL ';'
;

implementsStatement
	: IDENTIFIER_WEBIDL 'implements' IDENTIFIER_WEBIDL ';'
;

const_
	: 'const' constType IDENTIFIER_WEBIDL '=' constValue ';'
;

constValue
	: booleanLiteral
	| floatLiteral
	| INTEGER_WEBIDL
	| 'null'
;

booleanLiteral
	: 'true'
	| 'false'
;

floatLiteral
	: FLOAT_WEBIDL
	| '-Infinity'
	| 'Infinity'
	| 'NaN'
;

serializer
	: 'serializer' serializerRest
;

serializerRest
	: operationRest
	| '=' serializationPattern
	| 
;

serializationPattern
	: '{' serializationPatternMap '}'
	| '[' serializationPatternList ']'
	| IDENTIFIER_WEBIDL
;

serializationPatternMap
	: 'getter'
	| 'inherit' identifiers
	| IDENTIFIER_WEBIDL identifiers
	| 
;

serializationPatternList
	: 'getter'
	| IDENTIFIER_WEBIDL identifiers
	| 
;

stringifier
	: 'stringifier' stringifierRest
;

stringifierRest
	: readOnly attributeRest
	| returnType operationRest
	| ';'
;

staticMember
	: 'static' staticMemberRest
;

staticMemberRest
	: readOnly attributeRest
	| returnType operationRest
;

readonlyMember
	: 'readonly' readonlyMemberRest
;

readonlyMemberRest
	: attributeRest
	| maplikeRest
	| setlikeRest
;

readWriteAttribute
	: 'inherit' readOnly attributeRest
	| attributeRest
;

attributeRest
	: 'attribute' type IDENTIFIER_WEBIDL ';'
;

attributeName
	: attributeNameKeyword
	| IDENTIFIER_WEBIDL
;

attributeNameKeyword
	: 'required'
;

inherit
	: 'inherit'
	| 
;

readOnly
	: 'readonly'
	| 
;

operation
	: returnType operationRest
	| specialOperation
;

specialOperation
	: special specials returnType operationRest
;

specials
	: special specials
	| 
;

special
	: 'getter'
	| 'setter'
	| 'creator'
	| 'deleter'
	| 'legacycaller'
;

operationRest
	: optionalIdentifier '(' argumentList ')' ';'
;

optionalIdentifier
	: IDENTIFIER_WEBIDL
	| 
;

argumentList
	: argument arguments
	| 
;

arguments
	: ',' argument arguments
	| 
;

argument
	: extendedAttributeList optionalOrRequiredArgument
;

optionalOrRequiredArgument
	: 'optional' type argumentName default_
	| type ellipsis argumentName
;

argumentName
	: argumentNameKeyword
	| IDENTIFIER_WEBIDL
;

ellipsis
	: '...'
	| 
;

iterable
	: 'iterable' '<' type optionalType '>' ';'
	| 'legacyiterable' '<' type '>' ';'
;

optionalType
	: ',' type
	| 
;

readWriteMaplike
	: maplikeRest
;

readWriteSetlike
	: setlikeRest
;

maplikeRest
	: 'maplike' '<' type ',' type '>' ';'
;

setlikeRest
	: 'setlike' '<' type '>' ';'
;

extendedAttributeList
	: '[' extendedAttribute extendedAttributes ']'
	| 
;

extendedAttributes
	: ',' extendedAttribute extendedAttributes
	| 
;

extendedAttribute
	: '(' extendedAttributeInner ')' extendedAttributeRest
	| '[' extendedAttributeInner ']' extendedAttributeRest
	| '{' extendedAttributeInner '}' extendedAttributeRest
	| other extendedAttributeRest
;

extendedAttributeRest
	: extendedAttribute
	| 
;

extendedAttributeInner
	: '(' extendedAttributeInner ')' extendedAttributeInner
	| '[' extendedAttributeInner ']' extendedAttributeInner
	| '{' extendedAttributeInner '}' extendedAttributeInner
	| otherOrComma extendedAttributeInner
	| 
;

other
	: INTEGER_WEBIDL
	| FLOAT_WEBIDL
	| IDENTIFIER_WEBIDL
	| STRING_WEBIDL
	| OTHER_WEBIDL
	| '-'
	| '-Infinity'
	| '.'
	| '...'
	| ':'
	| ';'
	| '<'
	| '='
	| '>'
	| '?'
	| 'ByteString'
	| 'Date'
	| 'DOMString'
	| 'Infinity'
	| 'NaN'
	| 'RegExp'
	| 'USVString'
	| 'any'
	| 'boolean'
	| 'byte'
	| 'double'
	| 'false'
	| 'float'
	| 'long'
	| 'null'
	| 'object'
	| 'octet'
	| 'or'
	| 'optional'
	| 'sequence'
	| 'short'
	| 'true'
	| 'unsigned'
	| 'void'
	| argumentNameKeyword
	| bufferRelatedType
;

argumentNameKeyword
	: 'attribute'
	| 'callback'
	| 'const'
	| 'creator'
	| 'deleter'
	| 'dictionary'
	| 'enum'
	| 'getter'
	| 'implements'
	| 'inherit'
	| 'interface'
	| 'iterable'
	| 'legacycaller'
	| 'legacyiterable'
	| 'maplike'
	| 'partial'
	| 'required'
	| 'serializer'
	| 'setlike'
	| 'setter'
	| 'static'
	| 'stringifier'
	| 'typedef'
	| 'unrestricted'
;

otherOrComma
	: other
	| ','
;

type
	: singleType
	| unionType typeSuffix
;

singleType
	: nonAnyType
	| 'any' typeSuffixStartingWithArray
;

unionType
	: '(' unionMemberType 'or' unionMemberType unionMemberTypes ')'
;

unionMemberType
	: nonAnyType
	| unionType typeSuffix
	| 'any' '[' ']' typeSuffix
;

unionMemberTypes
	: 'or' unionMemberType unionMemberTypes
	| 
;

nonAnyType
	: primitiveType typeSuffix
	| promiseType null_
	| 'ByteString' typeSuffix
	| 'DOMString' typeSuffix
	| 'USVString' typeSuffix
	| IDENTIFIER_WEBIDL typeSuffix
	| 'sequence' '<' type '>' null_
	| 'object' typeSuffix
	| 'Date' typeSuffix
	| 'RegExp' typeSuffix
	| 'DOMException' typeSuffix
	| bufferRelatedType typeSuffix
;

bufferRelatedType
	: 'ArrayBuffer'
	| 'DataView'
	| 'Int8Array'
	| 'Int16Array'
	| 'Int32Array'
	| 'Uint8Array'
	| 'Uint16Array'
	| 'Uint32Array'
	| 'Uint8ClampedArray'
	| 'Float32Array'
	| 'Float64Array'
;

constType
	: primitiveType null_
	| IDENTIFIER_WEBIDL null_
;

primitiveType
	: unsignedIntegerType
	| unrestrictedFloatType
	| 'boolean'
	| 'byte'
	| 'octet'
;

unrestrictedFloatType
	: 'unrestricted' floatType
	| floatType
;

floatType
	: 'float'
	| 'double'
;

unsignedIntegerType
	: 'unsigned' integerType
	| integerType
;

integerType
	: 'short'
	| 'long' optionalLong
;

optionalLong
	: 'long'
	| 
;

promiseType
	: 'Promise' '<' returnType '>'
;

typeSuffix
	: '[' ']' typeSuffix
	| '?' typeSuffixStartingWithArray
	| 
;

typeSuffixStartingWithArray
	: '[' ']' typeSuffix
	| 
;

null_
	: '?'
	| 
;

returnType
	: type
	| 'void'
;

identifierList
	: IDENTIFIER_WEBIDL identifiers
;

identifiers
	: ',' IDENTIFIER_WEBIDL identifiers
	| 
;

extendedAttributeNoArgs
	: IDENTIFIER_WEBIDL
;

extendedAttributeArgList
	: IDENTIFIER_WEBIDL '(' argumentList ')'
;

extendedAttributeIdent
	: IDENTIFIER_WEBIDL '=' IDENTIFIER_WEBIDL
;

extendedAttributeIdentList
	: IDENTIFIER_WEBIDL '=' '(' identifierList ')'
;

extendedAttributeNamedArgList
	: IDENTIFIER_WEBIDL '=' IDENTIFIER_WEBIDL '(' argumentList ')'
;


INTEGER_WEBIDL
	: '-'?('0'([Xx][0-9A-Fa-f]+|[0-7]*)|[1-9][0-9]*)
;

FLOAT_WEBIDL
	: '-'?(([0-9]+'.'[0-9]*|[0-9]*'.'[0-9]+)([Ee][\+\-]?[0-9]+)?|[0-9]+[Ee][\+\-]?[0-9]+)
;

IDENTIFIER_WEBIDL
	: [A-Z_a-z][0-9A-Z_a-z]*
;

STRING_WEBIDL
	: '"'~['"']*'"'
;

WHITESPACE_WEBIDL
	: [\t\n\r ]+ -> channel(HIDDEN)
;

COMMENT_WEBIDL
	: ('//'~[\n\r]*|'/*'(.|'\n')*?'*/')+ -> channel(HIDDEN)
; 

OTHER_WEBIDL
	: ~[\t\n\r 0-9A-Z_a-z]
;
