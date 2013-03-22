package org.regeinc.lang.generator

import org.regeinc.lang.el.AndPrefix
import org.regeinc.lang.el.NotPrefix
import org.regeinc.lang.el.TypePrefix

class TypePrefixJ {
	var String arg;

	new(String arg){
		this.arg = arg
	}

	def compile(TypePrefix typePrefix)'''
		«IF typePrefix.andPrefix!=null»«compile(typePrefix.andPrefix)»«ENDIF»«
		IF typePrefix.typePrefix!=null» || «compile(typePrefix.typePrefix)»«ENDIF»'''

	def compile(AndPrefix andPrefix)'''
		«IF andPrefix.notPrefix!=null»«compile(andPrefix.notPrefix)»«ENDIF»«
		IF andPrefix.andPrefix!=null» && «compile(andPrefix.andPrefix)»«ENDIF»'''

	def compile(NotPrefix notPrefix)'''
		«IF notPrefix.NOT»!«ENDIF»«IF notPrefix.type!=null»«arg» instanceof «notPrefix.type.name»«ELSE»(«compile(notPrefix.typePrefix)»)«ENDIF»'''

	def applyConstraint(TypePrefix typePrefix)'''
		if(!(«compile(typePrefix)»)){
			throw new IllegalArgumentException("«arg» does not satisfy type prefixes declared");
		}
	'''		
}