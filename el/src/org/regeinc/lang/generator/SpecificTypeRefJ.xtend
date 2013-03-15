package org.regeinc.lang.generator

import org.regeinc.lang.el.OrTypePrefix
import org.regeinc.lang.el.AndTypePrefix
import org.regeinc.lang.el.NotTypePrefix
import org.regeinc.lang.el.TypePrefix

class SpecificTypeRefJ {
	var String arg;

	new(String arg){
		this.arg = arg
	}

	def compile(OrTypePrefix orTypePrefix)'''
		«IF orTypePrefix.andTypePrefix!=null»«compile(orTypePrefix.andTypePrefix)»«ENDIF»«
		IF orTypePrefix.orTypePrefix!=null» || «compile(orTypePrefix.orTypePrefix)»«ENDIF»'''

	def compile(AndTypePrefix andTypePrefix)'''
		«IF andTypePrefix.notTypePrefix!=null»«compile(andTypePrefix.notTypePrefix)»«ENDIF»«
		IF andTypePrefix.andTypePrefix!=null» && «compile(andTypePrefix.andTypePrefix)»«ENDIF»'''

	def compile(NotTypePrefix notTypePrefix)'''
		«IF notTypePrefix.NOT»!«ENDIF»«compile(notTypePrefix.typePrefix)»'''

	def compile(TypePrefix typePrefix)'''
		«IF typePrefix.type!=null»«arg» instanceof «typePrefix.type.name»«ELSE»(«compile(typePrefix.orTypePrefix)»)«ENDIF»'''

	def applyConstraint(OrTypePrefix orTypePrefix)'''
		if(!(«compile(orTypePrefix)»)){
			throw new IllegalArgumentException("«arg» does not satisfy type prefixes declared");
		}
	'''		
}