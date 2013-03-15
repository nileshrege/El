
package org.regeinc.lang;

/**
 * Initialization support for running Xtext languages 
 * without equinox extension registry
 */
public class ElStandaloneSetup extends ElStandaloneSetupGenerated{

	public static void doSetup() {
		new ElStandaloneSetup().createInjectorAndDoEMFRegistration();
	}
}

